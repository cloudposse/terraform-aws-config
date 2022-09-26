# ----------------------------------------------------------------------------------------------------------------------
# Enable and configure AWS Config
# ----------------------------------------------------------------------------------------------------------------------
module "aws_config_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  attributes = ["config"]
  context    = module.this.context
}

resource "aws_config_configuration_recorder" "recorder" {
  count    = module.this.enabled ? 1 : 0
  name     = module.aws_config_label.id
  role_arn = local.create_iam_role ? module.iam_role[0].arn : var.iam_role_arn
  recording_group {
    all_supported = false
    resource_types = [
      "AWS::AccessAnalyzer::Analyzer",
      "AWS::ApiGateway::Stage",
      "AWS::ApiGatewayV2::Stage",
      "AWS::CloudFront::Distribution",
      "AWS::ElasticLoadBalancing::LoadBalancer",
      "AWS::Route53Resolver::ResolverEndpoint",
      "AWS::Route53Resolver::ResolverRule",
      "AWS::Route53Resolver::ResolverRuleAssociation",
      "AWS::StepFunctions::Activity",
      "AWS::EC2::Host", "AWS::EC2::Instance", "AWS::EC2::VPC",
      "AWS::ElasticLoadBalancingV2::LoadBalancer", "AWS::IAM::Group", "AWS::IAM::Policy",
      "AWS::IAM::Role", "AWS::Lambda::Function", "AWS::RDS::DBCluster", "AWS::RDS::DBInstance",
      "AWS::S3::AccountPublicAccessBlock", "AWS::S3::Bucket", "AWS::EC2::Volume", "AWS::EKS::Cluster",
    "AWS::EC2::SecurityGroup", "AWS::CloudTrail::Trail", "AWS::KMS::Key"]
  }
}

resource "aws_config_delivery_channel" "channel" {
  count          = module.this.enabled ? 1 : 0
  name           = module.aws_config_label.id
  s3_bucket_name = var.s3_bucket_id
  s3_key_prefix  = var.s3_key_prefix
  sns_topic_arn  = local.findings_notification_arn

  depends_on = [
    aws_config_configuration_recorder.recorder,
    module.iam_role,
  ]
}

resource "aws_config_configuration_recorder_status" "recorder_status" {
  count      = module.this.enabled ? 1 : 0
  name       = aws_config_configuration_recorder.recorder[0].name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.channel]
}

resource "aws_config_config_rule" "rules" {
  for_each   = module.this.enabled ? var.managed_rules : {}
  depends_on = [aws_config_configuration_recorder_status.recorder_status]

  name        = each.key
  description = each.value.description

  source {
    owner             = "AWS"
    source_identifier = each.value.identifier
  }

  input_parameters = length(each.value.input_parameters) > 0 ? jsonencode(each.value.input_parameters) : null
  tags             = merge(module.this.tags, each.value.tags)
}

#-----------------------------------------------------------------------------------------------------------------------
# Optionally create an SNS topic and subscriptions
#-----------------------------------------------------------------------------------------------------------------------
module "sns_topic" {
  source  = "cloudposse/sns-topic/aws"
  version = "0.15.0"
  count   = module.this.enabled && local.create_sns_topic ? 1 : 0

  attributes      = concat(module.this.attributes, ["config"])
  subscribers     = var.subscribers
  sqs_dlq_enabled = false
  tags            = module.this.tags

  context = module.this.context
}

module "aws_config_findings_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  attributes = ["config", "findings"]

  context = module.this.context
}

#-----------------------------------------------------------------------------------------------------------------------
# Optionally create an IAM Role
#-----------------------------------------------------------------------------------------------------------------------
module "iam_role" {
  count   = module.this.enabled && local.create_iam_role ? 1 : 0
  source  = "cloudposse/iam-role/aws"
  version = "0.9.3"

  principals = {
    "Service" = ["config.amazonaws.com"]
  }

  use_fullname = true

  policy_documents = [
    data.aws_iam_policy_document.config_s3_policy[0].json,
    data.aws_iam_policy_document.config_sns_policy[0].json
  ]

  policy_document_count = 2
  policy_description    = "AWS Config IAM policy"
  role_description      = "AWS Config IAM role"

  attributes = ["config"]

  context = module.this.context
}

resource "aws_iam_role_policy_attachment" "config_policy_attachment" {
  count = module.this.enabled && local.create_iam_role ? 1 : 0

  role       = module.iam_role[0].name
  policy_arn = data.aws_iam_policy.aws_config_built_in_role.arn
}

data "aws_iam_policy" "aws_config_built_in_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

data "aws_iam_policy_document" "config_s3_policy" {
  count = local.create_iam_role ? 1 : 0

  statement {
    sid    = "ConfigS3"
    effect = "Allow"
    resources = [
      "${var.s3_bucket_arn}/*",
      var.s3_bucket_arn
    ]
    actions = [
      "s3:PutObject",
      "s3:GetBucketAcl"
    ]
    condition {
      test     = "StringLike"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

data "aws_iam_policy_document" "config_sns_policy" {
  count = local.create_iam_role && local.create_sns_topic ? 1 : 0

  statement {
    sid       = "ConfigSNS"
    effect    = "Allow"
    resources = [local.findings_notification_arn]
    actions = [
      "sns:Publish"
    ]
  }
}

#-----------------------------------------------------------------------------------------------------------------------
# CONFIG AGGREGATION
#-----------------------------------------------------------------------------------------------------------------------
module "aws_config_aggregator_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  attributes = ["config", "aggregator"]

  context = module.this.context
}

resource "aws_config_configuration_aggregator" "this" {
  # Create the aggregator in the global recorder region of the central AWS Config account. This is usually the
  # "security" account
  count = module.this.enabled && local.is_central_account && local.is_global_recorder_region ? 1 : 0

  name = module.aws_config_aggregator_label.id
  account_aggregation_source {
    account_ids = local.child_resource_collector_accounts
    all_regions = true
  }
}

resource "aws_config_aggregate_authorization" "child" {
  # Authorize each region in a child account to send its data to the global_resource_collector_region of the
  # central_resource_collector_account
  count = module.this.enabled && var.central_resource_collector_account != null ? 1 : 0

  account_id = var.central_resource_collector_account
  region     = var.global_resource_collector_region
}

resource "aws_config_aggregate_authorization" "central" {
  # Authorize each region to send its data to the global_resource_collector_region
  count = module.this.enabled ? 1 : 0

  account_id = data.aws_caller_identity.this.account_id
  region     = var.global_resource_collector_region
}


#-----------------------------------------------------------------------------------------------------------------------
# LOCALS AND DATA SOURCES
#-----------------------------------------------------------------------------------------------------------------------
data "aws_region" "this" {}
data "aws_caller_identity" "this" {}

locals {
  is_central_account                = var.central_resource_collector_account == data.aws_caller_identity.this.account_id
  is_global_recorder_region         = var.global_resource_collector_region == data.aws_region.this.name
  child_resource_collector_accounts = var.child_resource_collector_accounts != null ? var.child_resource_collector_accounts : []
  enable_notifications              = module.this.enabled && (var.create_sns_topic || var.findings_notification_arn != null)
  create_sns_topic                  = module.this.enabled && var.create_sns_topic
  findings_notification_arn         = local.enable_notifications ? (var.findings_notification_arn != null ? var.findings_notification_arn : module.sns_topic[0].sns_topic.arn) : null
  create_iam_role                   = module.this.enabled && var.create_iam_role
}

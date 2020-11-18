# ----------------------------------------------------------------------------------------------------------------------
# Enable and configure AWS Config
# ----------------------------------------------------------------------------------------------------------------------
module "aws_config_label" {
  source  = "cloudposse/label/null"
  version = "0.21.0"

  attributes = ["config"]
  context    = module.this.context
}
resource "aws_config_configuration_recorder" "recorder" {
  count    = module.this.enabled ? 1 : 0
  name     = module.aws_config_label.id
  role_arn = local.create_iam_role ? module.iam_role[0].arn : var.iam_role_arn
  recording_group {
    all_supported                 = true
    include_global_resource_types = var.include_global_resource_types
  }
}

resource "aws_config_delivery_channel" "channel" {
  count          = module.this.enabled ? 1 : 0
  name           = module.aws_config_label.id
  s3_bucket_name = module.aws_config_storage[0].bucket_id
  s3_key_prefix  = "foo"
  sns_topic_arn  = local.findings_notification_arn

  depends_on = [
    aws_config_configuration_recorder.recorder,
    module.aws_config_storage,
    module.iam_role,
  ]
}


# ----------------------------------------------------------------------------------------------------------------------
# Create an S3 Bucket for AWS Config rules to be stored
# ----------------------------------------------------------------------------------------------------------------------
module "aws_config_storage" {
  count = module.this.enabled ? 1 : 0
  #TODO: switch this once published to the registry
  source = "git::https://github.com/cloudposse/terraform-aws-config-storage.git?ref=feature/initial-implementation"

  force_destroy = var.force_destroy

  context = module.this.context
}

#-----------------------------------------------------------------------------------------------------------------------
# Optionally create an SNS topic and subscriptions 
#-----------------------------------------------------------------------------------------------------------------------
module "sns_topic" {
  source  = "cloudposse/sns-topic/aws"
  version = "0.9.0"
  count   = local.create_sns_topic ? 1 : 0

  attributes      = ["config"]
  subscribers     = var.subscribers
  sqs_dlq_enabled = false

  context = module.this.context
}

module "aws_config_findings_label" {
  source  = "cloudposse/label/null"
  version = "0.21.0"

  attributes = ["config-findings"]
  context    = module.this.context
}

resource "aws_sns_topic_policy" "sns_topic_publish_policy" {
  count  = local.create_sns_topic ? 1 : 0
  arn    = local.findings_notification_arn
  policy = data.aws_iam_policy_document.sns_topic_policy[0].json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  count = local.create_sns_topic ? 1 : 0

  policy_id = "__default_policy_ID"
  statement {

    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.this.account_id
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [module.sns_topic[0].sns_topic.arn]
    sid       = "__default_statement_ID"
  }
}

#-----------------------------------------------------------------------------------------------------------------------
# Optionally create an IAM Role 
#-----------------------------------------------------------------------------------------------------------------------
module "iam_role" {
  count   = local.create_iam_role ? 1 : 0
  source  = "cloudposse/iam-role/aws"
  version = "0.6.1"

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

  context = module.this.context
}

data "aws_iam_policy_document" "config_s3_policy" {
  count = local.create_iam_role ? 1 : 0

  statement {
    sid    = "ConfigS3"
    effect = "Allow"
    resources = [
      "${module.aws_config_storage[0].bucket_arn}/*",
      module.aws_config_storage[0].bucket_arn
    ]
    actions = [
      "s3:PutObject",
      "s3:GetBucketAcl"
    ]
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
# Locals and Data References
#-----------------------------------------------------------------------------------------------------------------------
locals {
  enable_notifications      = module.this.enabled && (var.create_sns_topic || var.findings_notification_arn != null)
  create_sns_topic          = module.this.enabled && var.create_sns_topic
  findings_notification_arn = local.enable_notifications ? (var.findings_notification_arn != null ? var.findings_notification_arn : module.sns_topic[0].sns_topic.arn) : null
  create_iam_role           = module.this.enabled && var.create_iam_role
}

data "aws_caller_identity" "this" {}
data "aws_partition" "this" {}
data "aws_region" "this" {}

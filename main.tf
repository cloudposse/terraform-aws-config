# ----------------------------------------------------------------------------------------------------------------------
# Enable and configure AWS Config
# ----------------------------------------------------------------------------------------------------------------------
module "aws_config_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = ["config"]
  context    = module.this.context
}

resource "aws_config_configuration_recorder" "recorder" {
  count    = module.this.enabled ? 1 : 0
  name     = module.aws_config_label.id
  role_arn = local.create_iam_role ? module.iam_role[0].arn : var.iam_role_arn
  recording_group {
    all_supported                 = true
    include_global_resource_types = local.is_global_recorder_region
  }

  dynamic "recording_mode" {
    for_each = var.recording_mode != null ? [1] : []
    content {
      recording_frequency = var.recording_mode.recording_frequency
      dynamic "recording_mode_override" {
        for_each = var.recording_mode.recording_mode_override != null ? [1] : []
        content {
          description         = var.recording_mode.recording_mode_override.description
          recording_frequency = var.recording_mode.recording_mode_override.recording_frequency
          resource_types      = var.recording_mode.recording_mode_override.resource_types
        }
      }
    }
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
  version = "0.20.1"
  count   = module.this.enabled && local.create_sns_topic ? 1 : 0

  attributes = concat(module.this.attributes, ["config"])
  subscribers = {
    for key, subscriber in var.subscribers : key => {
      protocol               = lookup(subscriber, "protocol")
      endpoint               = lookup(subscriber, "endpoint")
      endpoint_auto_confirms = lookup(subscriber, "endpoint_auto_confirms", false)
      raw_message_delivery   = lookup(subscriber, "raw_message_delivery", false)
    }
  }
  sqs_dlq_enabled = false

  kms_master_key_id           = var.sns_encryption_key_id
  sqs_queue_kms_master_key_id = var.sqs_queue_kms_master_key_id

  allowed_aws_services_for_sns_published = var.allowed_aws_services_for_sns_published
  allowed_iam_arns_for_sns_publish       = var.allowed_iam_arns_for_sns_publish

  tags = module.this.tags

  context = module.this.context
}

module "aws_config_findings_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = ["config", "findings"]

  context = module.this.context
}

#-----------------------------------------------------------------------------------------------------------------------
# Optionally create IAM Roles
#-----------------------------------------------------------------------------------------------------------------------
# Create Optional IAM ROLE for S3 bucket and SNS  
module "iam_role" {
  count   = module.this.enabled && local.create_iam_role ? 1 : 0
  source  = "cloudposse/iam-role/aws"
  version = "0.19.0"

  principals = {
    "Service" = ["config.amazonaws.com"]
  }

  use_fullname = true

  policy_documents = var.create_sns_topic ? [
    data.aws_iam_policy_document.config_s3_policy[0].json,
    data.aws_iam_policy_document.config_sns_policy[0].json
    ] : [
    data.aws_iam_policy_document.config_s3_policy[0].json
  ]

  policy_document_count = var.create_sns_topic ? 2 : 1
  policy_description    = "AWS Config IAM policy"
  role_description      = "AWS Config IAM role"

  attributes = ["config"]

  context = module.this.context
}

# Create Optional IAM ROLE for organization wide aggregator
module "iam_role_organization_aggregator" {
  count   = local.create_organization_aggregator_iam_role ? 1 : 0
  source  = "cloudposse/iam-role/aws"
  version = "0.19.0"

  principals = {
    "Service" = ["config.amazonaws.com"]
  }

  use_fullname = true

  policy_document_count = 0
  policy_description    = "AWS Config IAM policy for organization aggregator"
  role_description      = "AWS Config IAM role for organization aggregator"

  attributes = ["aggregator", "config"]

  context = module.this.context
}

resource "aws_iam_role_policy_attachment" "config_policy_attachment" {
  count = module.this.enabled && local.create_iam_role ? 1 : 0

  role       = module.iam_role[0].name
  policy_arn = data.aws_iam_policy.aws_config_built_in_role.arn
}

resource "aws_iam_role_policy_attachment" "organization_config_policy_attachment" {
  count = module.this.enabled && local.create_iam_role && var.is_organization_aggregator ? 1 : 0

  role       = module.iam_role_organization_aggregator[0].name
  policy_arn = data.aws_iam_policy.aws_config_organization_role.arn
}

data "aws_iam_policy" "aws_config_built_in_role" {
  arn = "arn:${local.partition}:iam::aws:policy/service-role/AWS_ConfigRole"
}

data "aws_iam_policy" "aws_config_organization_role" {
  arn = "arn:${local.partition}:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
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
  version = "0.25.0"

  attributes = ["config", "aggregator"]

  context = module.this.context
}

resource "aws_config_configuration_aggregator" "this" {
  # Create the aggregator in the global recorder region of the central AWS Config account. This is usually the
  # "security" account
  count = local.enabled && local.is_central_account && local.is_global_recorder_region ? 1 : 0

  name = module.aws_config_aggregator_label.id

  # Create normal account aggregation source
  dynamic "account_aggregation_source" {
    for_each = var.is_organization_aggregator ? [] : [1]
    content {
      account_ids = local.child_resource_collector_accounts
      all_regions = true
    }
  }

  # Create organization aggregation source
  dynamic "organization_aggregation_source" {
    for_each = var.is_organization_aggregator ? [1] : []
    content {
      all_regions = true
      role_arn    = local.create_organization_aggregator_iam_role ? module.iam_role_organization_aggregator[0].arn : var.iam_role_organization_aggregator_arn
    }
  }
  tags = module.this.tags
}

resource "aws_config_aggregate_authorization" "child" {
  # The following only occurs when Multi-Account Multi-Region Data Aggregation is enabled by supplying
  # `var.central_resource_collector_account` with an AWS Account ID:
  #
  # Authorize each region in a child account to send its data to the global_resource_collector_region of the
  # central_resource_collector_account
  count = local.enabled && var.central_resource_collector_account != null && var.is_organization_aggregator == false ? 1 : 0

  account_id = var.central_resource_collector_account
  region     = var.global_resource_collector_region

  tags = module.this.tags
}

resource "aws_config_aggregate_authorization" "central" {
  # The following only occurs when `var.central_resource_collector_account` is omitted, thus disabling
  # Multi-Account Multi-Region Data Aggregation and only enabling Multi-Region aggregation within the same account:
  #
  # Authorize each region to send its data to the global_resource_collector_region
  count = local.enabled && var.central_resource_collector_account == null && var.is_organization_aggregator == false ? 1 : 0

  account_id = data.aws_caller_identity.this.account_id
  region     = var.global_resource_collector_region

  tags = module.this.tags
}

#-----------------------------------------------------------------------------------------------------------------------
# LOCALS AND DATA SOURCES
#-----------------------------------------------------------------------------------------------------------------------
data "aws_region" "this" {}
data "aws_caller_identity" "this" {}
data "aws_partition" "current" {}

locals {
  enabled = module.this.enabled && !contains(var.disabled_aggregation_regions, data.aws_region.this.name)

  is_central_account                      = var.central_resource_collector_account == data.aws_caller_identity.this.account_id
  is_global_recorder_region               = var.global_resource_collector_region == data.aws_region.this.name
  child_resource_collector_accounts       = var.child_resource_collector_accounts != null ? var.child_resource_collector_accounts : []
  enable_notifications                    = module.this.enabled && (var.create_sns_topic || var.findings_notification_arn != null)
  create_sns_topic                        = module.this.enabled && var.create_sns_topic
  findings_notification_arn               = local.enable_notifications ? (var.findings_notification_arn != null ? var.findings_notification_arn : module.sns_topic[0].sns_topic.arn) : null
  create_iam_role                         = module.this.enabled && var.create_iam_role
  create_organization_aggregator_iam_role = module.this.enabled && var.create_organization_aggregator_iam_role
  partition                               = data.aws_partition.current.partition
}

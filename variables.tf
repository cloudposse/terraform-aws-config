variable "s3_bucket_id" {
  description = "The id (name) of the S3 bucket used to store the configuration history"
  type        = string
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket used to store the configuration history"
  type        = string
}

variable "create_sns_topic" {
  description = <<-DOC
    Flag to indicate whether an SNS topic should be created for notifications
    If you want to send findings to a new SNS topic, set this to true and provide a valid configuration for subscribers
  DOC

  type    = bool
  default = false
}

variable "sns_encryption_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK."
  type        = string
  default     = "" # Use "alias/aws/sns" for AWS Managed Key
}

variable "sqs_queue_kms_master_key_id" {
  type        = string
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SQS Queue or a custom CMK"
  default     = "" # Use "alias/aws/sqs" for AWS Managed Key
}

variable "subscribers" {
  type        = map(any)
  description = <<-DOC
    A map of subscription configurations for SNS topics

    For more information, see:
    https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription#argument-reference

    protocol:
      The protocol to use. The possible values for this are: sqs, sms, lambda, application. (http or https are partially
      supported, see link) (email is an option but is unsupported in terraform, see link).
    endpoint:
      The endpoint to send data to, the contents will vary with the protocol. (see link for more information)
    endpoint_auto_confirms (Optional):
      Boolean indicating whether the end point is capable of auto confirming subscription e.g., PagerDuty. Default is
      false
    raw_message_delivery (Optional):
      Boolean indicating whether or not to enable raw message delivery (the original message is directly passed, not wrapped in JSON with the original message in the message property). Default is false.
  DOC
  default     = {}
}

variable "findings_notification_arn" {
  description = <<-DOC
    The ARN for an SNS topic to send findings notifications to. This is only used if create_sns_topic is false.
    If you want to send findings to an existing SNS topic, set the value of this to the ARN of the existing topic and set
    create_sns_topic to false.
  DOC
  default     = null
  type        = string
}


variable "create_iam_role" {
  description = "Flag to indicate whether an IAM Role should be created to grant the proper permissions for AWS Config"
  type        = bool
  default     = false
}

variable "iam_role_arn" {
  description = <<-DOC
    The ARN for an IAM Role AWS Config uses to make read or write requests to the delivery channel and to describe the
    AWS resources associated with the account. This is only used if create_iam_role is false.

    If you want to use an existing IAM Role, set the value of this to the ARN of the existing topic and set
    create_iam_role to false.

    See the AWS Docs for further information:
    http://docs.aws.amazon.com/config/latest/developerguide/iamrole-permissions.html
  DOC
  default     = null
  type        = string
}

variable "global_resource_collector_region" {
  description = "The region that collects AWS Config data for global resources such as IAM"
  type        = string
}

variable "central_resource_collector_account" {
  description = "The account ID of a central account that will aggregate AWS Config from other accounts"
  type        = string
  default     = null
}

variable "child_resource_collector_accounts" {
  description = "The account IDs of other accounts that will send their AWS Configuration to this account"
  type        = set(string)
  default     = null
}

variable "force_destroy" {
  type        = bool
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable"
  default     = false
}

variable "managed_rules" {
  description = <<-DOC
    A list of AWS Managed Rules that should be enabled on the account.

    See the following for a list of possible rules to enable:
    https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html
  DOC
  type = map(object({
    description      = string
    identifier       = string
    input_parameters = any
    tags             = map(string)
    enabled          = bool
  }))
  default = {}
}

variable "s3_key_prefix" {
  type        = string
  description = <<-DOC
    The prefix for AWS Config objects stored in the the S3 bucket. If this variable is set to null, the default, no
    prefix will be used.

    Examples:

    with prefix:    {S3_BUCKET NAME}:/{S3_KEY_PREFIX}/AWSLogs/{ACCOUNT_ID}/Config/*.
    without prefix: {S3_BUCKET NAME}:/AWSLogs/{ACCOUNT_ID}/Config/*.
  DOC
  default     = null
}

// Config aggregation isn't enabled for ap-northeast-3, maybe others in the future
// https://docs.aws.amazon.com/config/latest/developerguide/aggregate-data.html
variable "disabled_aggregation_regions" {
  type        = list(string)
  description = "A list of regions where config aggregation is disabled"
  default     = ["ap-northeast-3"]
}

variable "region" {
  type        = string
  description = "AWS Region"
}
variable "create_iam_role" {
  description = "Flag to indicate whether an IAM Role should be created to grant the proper permissions for AWS Config"
  type        = bool
  default     = false
}

variable "create_sns_topic" {
  description = <<-DOC
    Flag to indicate whether an SNS topic should be created for notifications
    If you want to send findings to a new SNS topic, set this to true and provide a valid configuration for subscribers
  DOC

  type    = bool
  default = false
}

variable "force_destroy" {
  type        = bool
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable"
  default     = false
}

variable "cloudtrail_bucket_name" {
  description = <<-DOC
    The name of the S3 bucket where CloudTrail logs are being sent. This is needed to comply with 2.6 of the Benchmark 
    which states:

    Ensure S3 bucket access logging is enabled on the CloudTrail S3 bucket
  DOC
  type        = string
}

variable "is_logging_account" {
  description = <<-DOC
    Flag to indicate if this instance of AWS Config is being installed into a centralized logging account. If this flag
    is set to true, then the config rules associated with logging in the catalog (loggingAccountOnly: true) will be 
    installed. If false, they will not be installed.
    installed.
  DOC
  type        = bool
  default     = false
}

variable "parameter_overrides" {
  type        = map(map(string))
  description = <<-DOC
    Map of parameters for interpolation within the YAML config templates

    For example, to override the maxCredentialUsageAge parameter in the access-keys-rotated.yaml rule, you would specify
    the following:

    parameter_overrides = {
      "access-keys-rotated" : { maxCredentialUsageAge : "120" }
    }
  DOC
  default     = {}
}

variable "global_resource_collector_region" {
  description = "The region that collects AWS Config data for global resources such as IAM"
  type        = string
}

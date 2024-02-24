variable "support_policy_arn" {
  description = <<-DOC
    The ARN of the IAM Policy required for compliance with 1.20 of the Benchmark, which states:

    Ensure a support role has been created to manage incidents with AWS Support

    AWS provides a support center that can be used for incident notification and response, as well as technical support
    and customer services.

    Create an IAM role to allow authorized users to manage incidents with AWS Support. By implementing least privilege
    for access control, an IAM role will require an appropriate IAM policy to allow support center access in order to
    manage incidents with AWS Support.
  DOC
  type        = string
}

variable "cloudtrail_bucket_name" {
  description = <<-DOC
    The name of the S3 bucket where CloudTrail logs are being sent. This is needed to comply with 2.6 of the Benchmark
    which states:

    Ensure S3 bucket access logging is enabled on the CloudTrail S3 bucket
  DOC
  type        = string
}

variable "config_rules_paths" {
  description = "Set of PATH'es to files with config rules"
  type        = set(string)
  default = [
    "../../catalog/cloudtrail.yaml",
    "../../catalog/cmk.yaml",
    "../../catalog/iam.yaml",
    "../../catalog/network.yaml",
    "../../catalog/vpc.yaml",
  ]
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

variable "is_global_resource_region" {
  description = <<-DOC
    Flag to indicate if this instance of AWS Config is being installed to monitor global resources (such as IAM). In
    order to save money, you can disable the monitoring of global resources in all but region. If this flag is set to
    true, then the config rules associated with global resources in the catalog (globalResource: true) will be
    installed. If false, they will not be installed.
  DOC
  type        = bool
  default     = false
}

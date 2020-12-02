variable "config_rules_paths" {
  default = [
    "../../catalog/cloudtrail/*.yaml",
    "../../catalog/iam/*.yaml",
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

variable "is_global_reource_region" {
  description = <<-DOC
    Flag to indicate if this instance of AWS Config is being installed to monitor global resources (such as IAM). In
    order to save money, you can disable the monitoring of global resources in all but region. If this flag is set to 
    true, then the config rules associated with global resources in the catalog (globalResource: true) will be 
    installed. If false, they will not be installed.
  DOC
  type        = bool
  default     = false
}

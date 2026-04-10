variable "region" {
  description = "The AWS region where resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "force_destroy" {
  description = "Whether to force destroy resources that have dependencies."
  type        = bool
  default     = true
}

variable "create_sns_topic" {
  description = "Whether to create an SNS topic for Config notifications."
  type        = bool
  default     = true
}

variable "create_iam_role" {
  description = "Whether to create an IAM role for Config."
  type        = bool
  default     = true
}

variable "global_resource_collector_region" {
  description = "The AWS region for the global resource collector."
  type        = string
  default     = "us-east-1"
}

variable "managed_rules" {
  description = "Configuration for AWS managed rules."
  type = map(object({
    description      = string
    identifier       = string
    input_parameters = any
    tags             = map(string)
    enabled          = bool
  }))
  default = {
    account-part-of-organizations = {
      description      = "Checks whether AWS account is part of AWS Organizations."
      identifier       = "ACCOUNT_PART_OF_ORGANIZATIONS"
      input_parameters = {}
      tags             = {}
      enabled          = true
    }
  }
}

variable "custom_lambda_rules" {
  description = "Custom Lambda-based Config rules."
  type = map(object({
    description         = string
    lambda_function_arn = string
    input_parameters    = optional(any, {})
    source_identifier   = optional(string, null)
    scope = optional(object({
      compliance_resource_types = optional(list(string), [])
    }), null)
    tags    = optional(map(string), {})
    enabled = bool
  }))
  default = {
    example_custom_lambda = {
      description         = "Custom Lambda rule for evaluating EC2 instance tags."
      lambda_function_arn = "arn:aws:lambda:us-east-1:123456789012:function:ConfigRuleFunction"
      input_parameters = {
        requiredTags = "Environment,CostCenter"
      }
      scope = {
        compliance_resource_types = ["AWS::EC2::Instance"]
      }
      tags = {
        Type = "Custom"
      }
      enabled = false # Set to true to enable
    }
  }
}

variable "custom_policy_rules" {
  description = "Custom policy-based Config rules using CFN Guard."
  type = map(object({
    description      = string
    policy           = optional(string, null)
    policy_runtime   = optional(string, "guard-2.x.x")
    input_parameters = optional(any, {})
    scope = optional(object({
      compliance_resource_types = optional(list(string), [])
    }), null)
    tags    = optional(map(string), {})
    enabled = bool
  }))
  default = {
    example_cfn_guard_rule = {
      description    = "CFN Guard rule for checking security group configurations."
      policy_runtime = "guard-2.x.x"
      policy         = <<-EOT
        rule sg_restricted_ingress {
          aws_security_group.SecurityGroupIngress[*]  {
            cidr_ip != "0.0.0.0/0"
          }
        }
      EOT
      input_parameters = {
        check_name = "security_group_ingress"
      }
      scope = {
        compliance_resource_types = ["AWS::EC2::SecurityGroup"]
      }
      tags = {
        Type = "Policy"
      }
      enabled = false # Set to true to enable
    }
  }
}

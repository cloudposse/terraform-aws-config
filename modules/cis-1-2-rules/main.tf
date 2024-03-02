locals {
  current_region = module.utils.region_az_alt_code_maps.to_fixed[data.aws_region.current.name]

  file_rules      = module.aws_config_rules_yaml_config.map_configs
  rules_with_tags = { for k, rule in local.file_rules : k => rule if rule.tags != null }

  compliance_standard_tag = "compliance/cis-aws-foundations/1.2"
  logging_only_tag        = "compliance/cis-aws-foundations/filters/logging-account-only"
  global_only_tag         = "compliance/cis-aws-foundations/filters/global-resource-region-only"
  region_exclusion_tag    = "region/excluded/${local.current_region}"

  tagged_rules          = { for key, rule in local.rules_with_tags : key => rule if lookup(rule.tags, local.compliance_standard_tag, false) == true }
  logging_account_rules = { for key, rule in local.tagged_rules : key => rule if var.is_logging_account && lookup(rule.tags, local.logging_only_tag, false) && !lookup(rule.tags, local.region_exclusion_tag, false) }
  global_resource_rules = { for key, rule in local.tagged_rules : key => rule if var.is_global_resource_region && lookup(rule.tags, local.global_only_tag, false) && !lookup(rule.tags, local.region_exclusion_tag, false) }
  base_rules            = { for key, rule in local.tagged_rules : key => rule if(!lookup(rule.tags, local.logging_only_tag, false) && !lookup(rule.tags, local.global_only_tag, false) && !lookup(rule.tags, local.region_exclusion_tag, false)) }
  all_rules             = merge(local.base_rules, local.logging_account_rules, local.global_resource_rules)

  base_params = {

    "s3-bucket-logging-enabled" : {
      "targetBucket" : var.cloudtrail_bucket_name
    }
    "multi-region-cloudtrail-enabled" : {
      "s3BucketName" : var.cloudtrail_bucket_name
    }
  }

  global_resource_params = {
    "iam-policy-in-use" : {
      "policyARN" : var.support_policy_arn
    }
  }

  params = var.is_global_resource_region ? merge(local.base_params, local.global_resource_params) : local.base_params

  enabled_rules = { for key, rule in local.all_rules : key => {
    description      = rule.description,
    identifier       = rule.identifier,
    input_parameters = merge(rule.inputParameters, lookup(local.params, key, {}), lookup(var.parameter_overrides, key, {})),
    tags             = rule.tags,
    enabled          = rule.enabled,
  } if module.this.enabled }
}

module "aws_config_rules_yaml_config" {
  source  = "cloudposse/config/yaml"
  version = "1.0.2"

  map_config_local_base_path = path.module
  map_config_paths           = var.config_rules_paths

  context = module.this.context
}

data "aws_region" "current" {}

module "utils" {
  source  = "cloudposse/utils/aws"
  version = "1.0.0"
}

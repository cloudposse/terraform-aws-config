locals {
  file_rules      = module.aws_config_rules_yaml_config.map_configs
  rules_with_tags = { for k, rule in local.file_rules : k => rule if rule.tags != null }

  compliance_standard_tag = "compliance/cis-aws-foundations/1.2"
  logging_only_tag        = "compliance/cis-aws-foundations/filters/logging-account-only"
  global_only_tag         = "compliance/cis-aws-foundations/filters/global-resource-region-only"

  tagged_rules          = { for key, rule in local.rules_with_tags : key => rule if lookup(rule.tags, local.compliance_standard_tag, false) == true }
  logging_account_rules = { for key, rule in local.tagged_rules : key => rule if var.is_logging_account && lookup(rule.tags, local.logging_only_tag, false) }
  global_resource_rules = { for key, rule in local.tagged_rules : key => rule if var.is_global_resource_region && lookup(rule.tags, local.global_only_tag, false) }
  base_rules            = { for key, rule in local.tagged_rules : key => rule if(! lookup(rule.tags, local.logging_only_tag, false) && ! lookup(rule.tags, local.global_only_tag, false)) }
  all_rules             = merge(local.base_rules, local.logging_account_rules, local.global_resource_rules)

  params = {
    "iam-policy-in-use" : {
      "policyARN" : var.support_policy_arn
    }
    "s3-bucket-logging-enabled" : {
      "targetBucket" : var.cloudtrail_bucket_name
    }
    "multi-region-cloudtrail-enabled" : {
      "s3BucketName" : var.cloudtrail_bucket_name
    }
  }

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
  version = "0.1.0"

  map_config_local_base_path = path.module
  map_config_paths           = var.config_rules_paths

  context = module.this.context
}

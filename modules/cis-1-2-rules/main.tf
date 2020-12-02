locals {
  all_rules       = module.aws_config_rules_yaml_config.map_configs
  rules_with_tags = { for k, rule in local.all_rules : k => rule if rule.tags != null }

  cis_1_2_tag      = "compliance/cis-aws-foundations/1.2"
  logging_only_tag = "compliance/cis-aws-foundations/filters/logging-account-only"
  global_only_tag  = "compliance/cis-aws-foundations/filters/global-resource-region-only"

  cis_1_2_tagged_rules          = { for key, rule in local.rules_with_tags : key => rule if lookup(rule.tags, local.cis_1_2_tag, false) == true }
  cis_1_2_logging_account_rules = { for key, rule in local.cis_1_2_tagged_rules : key => rule if var.is_logging_account && lookup(rule.tags, local.logging_only_tag, false) }
  cis_1_2_global_resource_rules = { for key, rule in local.cis_1_2_tagged_rules : key => rule if var.is_global_reource_region && lookup(rule.tags, local.global_only_tag, false) }
  cis_1_2_base_rules            = { for key, rule in local.cis_1_2_tagged_rules : key => rule if(! lookup(rule.tags, local.logging_only_tag, false) && ! lookup(rule.tags, local.global_only_tag, false)) }
  cis_1_2_all_rules             = merge(local.cis_1_2_base_rules, local.cis_1_2_logging_account_rules, local.cis_1_2_global_resource_rules)

  cis_params = {
    iam-policy-in-use: {
      policyArn: var.support_policy_arn
    s3-bucket-logging-enabled: {
      targetBucket: var.cloudtrail_bucket_name
    multi-region-cloudtrail-enabled:
      s3BucketName: var.cloudtrail_bucket_name
    }
  }

  cis_1_2_enabled_rules = { for key, rule in local.cis_1_2_all_rules : key => {
    "description"      = rule.description,
    "identifier"       = rule.identifier,
    "input_parameters" = merge(rule.inputParameters, local.cis_params, lookup(var.parameter_overrides, key, {})),
    "tags"             = rule.tags,
    "enabled"          = rule.enabled,
  } if module.this.enabled }

  all_enabled_rules = merge(local.cis_1_2_enabled_rules)
}

module "aws_config_rules_yaml_config" {
  source  = "cloudposse/config/yaml"
  version = "0.1.0"

  map_config_local_base_path = path.module
  map_config_paths           = var.config_rules_paths

  context = module.this.context
}

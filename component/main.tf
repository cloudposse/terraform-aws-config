locals {
  all_rules       = module.aws_config_rules_yaml_config.map_configs
  rules_with_tags = { for k, rule in local.all_rules : k => rule if rule.tags != null }

  cis_1_2_tag                   = "compliance/standards/aws-foundations-cis/1.2"
  cis_1_2_tagged_rules          = { for key, rule in local.rules_with_tags : key => rule if lookup(rule.tags, local.cis_1_2_tag, false) == true }
  cis_1_2_logging_account_rules = { for key, rule in local.cis_1_2_tagged_rules : key => rule if var.is_logging_account && lookup(rule, "loggingAccountOnly", false) }
  cis_1_2_global_resource_rules = { for key, rule in local.cis_1_2_tagged_rules : key => rule if var.is_global_reource_region && lookup(rule, "globalResource", false) }
  cis_1_2_base_rules            = { for key, rule in local.cis_1_2_tagged_rules : key => rule if(! lookup(rule, "loggingAccountOnly", false) && ! lookup(rule, "globalResource", false)) }
  cis_1_2_all_rules             = merge(local.cis_1_2_base_rules, local.cis_1_2_logging_account_rules, local.cis_1_2_global_resource_rules)
  cis_1_2_enabled_rules = { for key, rule in local.cis_1_2_all_rules : key => {
    "description"      = rule.description,
    "identifier"       = rule.identifier,
    "input_parameters" = rule.inputParameters,
    "tags"             = rule.tags,
    "enabled"          = rule.enabled,
  } if var.enable_cis_1_2 }

  all_enabled_rules = merge(local.cis_1_2_enabled_rules)
}

# Convert all Service Control Policy statements from YAML config to Terraform list
module "aws_config_rules_yaml_config" {
  source  = "cloudposse/config/yaml"
  version = "0.1.0"

  map_config_local_base_path = path.module
  map_config_paths           = var.config_rules_paths

  context = module.this.context
}

# Provision AWS Config for this account/region
module "aws_config" {
  enabled = false
  source  = "../"
  #version = "0.1.0"

  create_sns_topic = true
  create_iam_role  = true
  force_destroy    = true
  managed_rules    = local.all_enabled_rules

  context = module.this.context
}

output "enabled_rules" {
  value = local.all_enabled_rules
}

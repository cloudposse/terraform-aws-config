provider "aws" {
  region = var.region
}

module "aws_config" {
  source = "../.."

  create_sns_topic = var.create_sns_topic
  create_iam_role  = var.create_iam_role
  managed_rules    = var.managed_rules
  force_destroy    = var.force_destroy

  context = module.this.context
}

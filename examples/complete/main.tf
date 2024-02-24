provider "aws" {
  region = var.region
}

locals {
  subscribers = {
    email = {
      protocol               = "email"
      endpoint               = "test@example.com"
      endpoint_auto_confirms = true
    }
  }
}

module "aws_config_storage" {
  source  = "cloudposse/config-storage/aws"
  version = "1.0.0"

  force_destroy = var.force_destroy
  tags          = module.this.tags

  context = module.this.context
}

module "aws_config" {
  source = "../.."

  create_sns_topic                 = var.create_sns_topic
  create_iam_role                  = var.create_iam_role
  managed_rules                    = var.managed_rules
  force_destroy                    = var.force_destroy
  s3_bucket_id                     = module.aws_config_storage.bucket_id
  s3_bucket_arn                    = module.aws_config_storage.bucket_arn
  global_resource_collector_region = var.global_resource_collector_region
  subscribers                      = local.subscribers

  context = module.this.context
}

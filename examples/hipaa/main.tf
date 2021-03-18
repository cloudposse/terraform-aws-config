provider "aws" {
  region = var.region
}

module "aws_config_storage" {
  source  = "cloudposse/config-storage/aws"
  version = "0.4.0"

  force_destroy = var.force_destroy
  tags          = module.this.tags

  context = module.this.context
}

module "aws_config" {
  source = "../.."

  create_sns_topic                 = var.create_sns_topic
  create_iam_role                  = var.create_iam_role
  force_destroy                    = var.force_destroy
  s3_bucket_id                     = module.aws_config_storage.bucket_id
  s3_bucket_arn                    = module.aws_config_storage.bucket_arn
  global_resource_collector_region = data.aws_region.current.name

  context = module.this.context
}

module "hipaa_conformance_pack" {
  source  = "../../modules/hipaa-conformance-pack"
  context = module.this.context
  depends_on = [
    module.aws_config
  ]
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

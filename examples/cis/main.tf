provider "aws" {
  region = var.region
}

module "test_label" {
  source  = "cloudposse/label/null"
  version = "0.22.1"

  attributes = ["test", "policy"]
  context    = module.this.context
}

resource "aws_iam_role" "support_role" {
  name = module.test_label.id

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
EOF
}

resource "aws_iam_policy" "support_policy" {
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "support:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "support_policy_attach" {
  name       = module.test_label.id
  roles      = [aws_iam_role.support_role.name]
  policy_arn = aws_iam_policy.support_policy.arn
}

module "cis_rules" {
  source = "../../modules/cis-1-2-rules"

  is_logging_account     = var.is_logging_account
  support_policy_arn     = aws_iam_policy.support_policy.arn
  cloudtrail_bucket_name = var.cloudtrail_bucket_name
  parameter_overrides    = var.parameter_overrides

  context = module.this.context
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
  managed_rules                    = module.cis_rules.rules
  force_destroy                    = var.force_destroy
  s3_bucket_id                     = module.aws_config_storage.bucket_id
  s3_bucket_arn                    = module.aws_config_storage.bucket_arn
  global_resource_collector_region = var.global_resource_collector_region

  context = module.this.context
}

data "aws_caller_identity" "current" {}

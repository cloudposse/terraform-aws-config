output "config_recorder_id" {
  value       = module.aws_config.aws_config_configuration_recorder_id
  description = "The ID of the AWS Config Recorder."
}

output "custom_lambda_rule_arns" {
  value       = module.aws_config.custom_lambda_rule_arns
  description = "ARNs of custom Lambda rules."
}

output "custom_policy_rule_arns" {
  value       = module.aws_config.custom_policy_rule_arns
  description = "ARNs of custom policy rules."
}

output "storage_bucket_id" {
  value       = module.aws_config_storage.bucket_id
  description = "Name of the S3 bucket used for AWS Config storage."
}

output "sns_topic" {
  value       = module.aws_config.sns_topic
  description = "SNS topic for AWS Config notifications."
}

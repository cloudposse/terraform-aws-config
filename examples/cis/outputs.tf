output "enabled_rules" {
  value = module.cis_rules.rules
}

output "config_recorder_id" {
  value       = module.aws_config.aws_config_configuration_recorder_id
  description = "The id of the AWS Config Recorder that was created"
}

output "storage_bucket_id" {
  value       = module.aws_config_storage.bucket_id
  description = "Bucket Name (aka ID)"
}

output "storage_bucket_arn" {
  value       = module.aws_config_storage.bucket_arn
  description = "Bucket ARN"
}

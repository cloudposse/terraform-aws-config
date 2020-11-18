output "id" {
  value       = module.example.aws_config_configuration_recorder_id
  description = "The id of the AWS Config Recorder that was created"
}

output "storage_bucket_id" {
  value       = module.example.storage_bucket_id
  description = "Bucket Name (aka ID)"
}

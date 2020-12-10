output "config_recorder_id" {
  value       = module.aws_config.aws_config_configuration_recorder_id
  description = "The id of the AWS Config Recorder that was created"
}

output "storage_bucket_id" {
  value       = module.aws_config.storage_bucket_id
  description = "Bucket Name (aka ID)"
}

output "iam_role" {
  description = <<-DOC
  IAM Role used to make read or write requests to the delivery channel and to describe the AWS resources associated with 
  the account.
  DOC
  value       = module.aws_config.iam_role
}

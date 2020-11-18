output "aws_config_configuration_recorder_id" {
  value       = join("", aws_config_configuration_recorder.recorder.*.id)
  description = "The id of the AWS Config Recorder that was created"
}

output "storage_bucket_id" {
  value       = join("", module.aws_config_storage.*.bucket_id)
  description = "Bucket Name (aka ID)"
}

output "storage_bucket_arn" {
  value       = join("", module.aws_config_storage.*.bucket_arn)
  description = "Bucket ARN"
}

output "sns_topic" {
  description = "The SNS topic that was created"
  value       = local.create_sns_topic ? module.sns_topic[0].sns_topic : null
}

output "sns_topic_subscriptions" {
  description = "The SNS topic that was created"
  value       = local.create_sns_topic ? module.sns_topic[0].aws_sns_topic_subscriptions : null
}

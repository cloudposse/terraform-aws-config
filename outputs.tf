output "aws_config_configuration_recorder_id" {
  value       = join("", aws_config_configuration_recorder.recorder[*].id)
  description = "The ID of the AWS Config Recorder"
}

output "storage_bucket_id" {
  value       = var.s3_bucket_id
  description = "Bucket Name (aka ID)"
}

output "storage_bucket_arn" {
  value       = var.s3_bucket_arn
  description = "Bucket ARN"
}

output "iam_role" {
  description = <<-DOC
  IAM Role used to make read or write requests to the delivery channel and to describe the AWS resources associated with 
  the account.
  DOC
  value       = local.create_iam_role ? module.iam_role[0].arn : var.iam_role_arn
}

output "iam_role_organization_aggregator" {
  description = <<-DOC
  IAM Role used to make read or write requests to the delivery channel and to describe the AWS resources associated with 
  the account.
  DOC
  value       = local.create_organization_aggregator_iam_role ? module.iam_role_organization_aggregator[0].arn : var.iam_role_organization_aggregator_arn
}

output "sns_topic" {
  description = "SNS topic"
  value       = local.create_sns_topic ? module.sns_topic[0].sns_topic : null
}

output "sns_topic_subscriptions" {
  description = "SNS topic subscriptions"
  value       = local.create_sns_topic ? module.sns_topic[0].aws_sns_topic_subscriptions : null
}

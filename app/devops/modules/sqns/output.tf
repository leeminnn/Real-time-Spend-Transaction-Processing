output "sqs_campaign_url" {
  value = aws_sqs_queue.itsag1t5_campaign_sqs.id
}

output "sqs_transaction_url" {
  value = aws_sqs_queue.itsag1t5_transaction_sqs.id
}

output "sqs_user_url" {
  value = aws_sqs_queue.itsag1t5_user_processing_sqs.id
}

output "sqs_user_name" {
  value = aws_sqs_queue.itsag1t5_user_processing_sqs.name
}

output "sns_transaction_topic_arn" {
  value = aws_sns_topic.itsag1t5_transaction_sns.arn
}
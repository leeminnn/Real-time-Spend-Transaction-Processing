variable "exavault_credential_string" {
  description = "The credentials for Exavault SFTP"
  nullable    = false
  sensitive   = true
  type        = map(string)
}

variable "transaction_sns_topic_arn" {
  description = "The SNS topic ARN for transaction notifications"
  nullable    = false
  type        = string
}

variable "user_sqs" {
  description = "The SQS URL for user notifications"
  nullable    = false
  type        = string
}

variable "vpc_id" {
  description = "The CIDR block of the vpc"
}

variable "private_subnets" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
}

variable "rds_credential_string" {
  description = "The credentials for RDS"
  nullable    = false
  sensitive   = true
  type        = map(string)
}

variable "rds_master_username" {
  description = "The master username for RDS"
  nullable    = false
  sensitive   = true
  type        = string
}


variable "rds_master_password" {
  description = "The master password for RDS"
  nullable    = false
  sensitive   = true
  type        = string
}

variable "rds_database_name" {
  description = "The database name for RDS"
  nullable    = false
  type        = string
}

variable "jwt_secret" {
  description = "JWT Secret"
  nullable    = false
  sensitive   = true
  type        = string
}

variable "rds_rr_endpoint" {
  description = "RDS Read Replica Endpoint"
  nullable    = false
  type        = string
}


variable "rds_writer_endpoint" {
  description = "RDS Read Replica Endpoint"
  nullable    = false
  type        = string
}

variable "public_subnets" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
}


variable "environment_prefix" {
  type        = string
  description = "Prefix before resource name"
}

variable "region" {
  type        = string
  description = "The region that the resources will be launched"
}

variable "sqs_campaign_url" {
  type        = string
  description = "The url for the SQS campaign queue"
}

variable "sqs_user_url" {
  type        = string
  description = "The url for the SQS user queue"
}

variable "sqs_user_name" {
  type        = string
  description = "The name for the SQS user queue"
}

variable "sqs_transaction_url" {
  type        = string
  description = "The url for the SQS transaction queue"
}
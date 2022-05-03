variable "rds_username" {
  type        = string
  description = "The username for the RDS instance"
  nullable    = false
  sensitive   = true
}

variable "rds_password" {
  type        = string
  description = "The password for the RDS instance"
  nullable    = false
  sensitive   = true
}

variable "private_subnets" {
  type = list(string)
  description = "The IDs of the private subnets"
}
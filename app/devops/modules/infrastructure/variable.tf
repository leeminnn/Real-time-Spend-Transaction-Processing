# Networking
variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
}

variable "availability_zones" {
  type        = list(any)
  description = "The az that the resources will be launched"
}

variable "environment_prefix" {
  type        = string
  description = "Prefix before resource name"
}

variable "region" {
  type        = string
  description = "The region that the resources will be launched"
}
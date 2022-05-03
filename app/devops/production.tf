module "infrastructure" {
  source               = "./modules/infrastructure"
  environment_prefix   = var.environment_prefix
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = var.availability_zone
  region               = var.region
}

module "lambda" {
  source                     = "./modules/lambda"
  exavault_credential_string = var.exavault_credential_string
  transaction_sns_topic_arn  = module.sqns.sns_transaction_topic_arn
  user_sqs                   = module.sqns.sqs_user_name
}

module "rds" {
  source          = "./modules/rds"
  rds_username    = var.rds_username
  rds_password    = var.rds_password
  private_subnets = module.infrastructure.private_subnets
}

module "sqns" {
  source = "./modules/sqns"
}

module "frontend" {
  source = "./modules/frontend"
}

module "dynamo" {
  source = "./modules/dynamodb"
}

module "route53" {
  source             = "./modules/route53"
  environment_prefix = var.environment_prefix
}

module "fargate" {
  source             = "./modules/fargate"
  vpc_id             = module.infrastructure.vpc_id
  region             = var.region
  public_subnets     = module.infrastructure.public_subnets
  private_subnets    = module.infrastructure.private_subnets
  environment_prefix = var.environment_prefix

  jwt_secret            = var.jwt_secret
  rds_writer_endpoint   = module.rds.rds_writer_endpoint.0
  rds_rr_endpoint       = module.rds.rds_read_replica_endpoint.0
  rds_database_name     = var.rds_database
  rds_master_username   = var.rds_username
  rds_master_password   = var.rds_password
  rds_credential_string = var.rds_user_activity_service_credential_string

  sqs_campaign_url    = module.sqns.sqs_campaign_url
  sqs_user_url        = module.sqns.sqs_user_url
  sqs_transaction_url = module.sqns.sqs_transaction_url
  sqs_user_name       = module.sqns.sqs_user_name
}

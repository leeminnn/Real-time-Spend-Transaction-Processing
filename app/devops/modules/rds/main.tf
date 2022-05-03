resource "aws_db_subnet_group" "itsag1t5_rds_private_subnet_grp" {
  name       = "itsag1t5-rds-private-subnet-grp"
  subnet_ids = var.private_subnets
}

resource "aws_rds_cluster" "itsag1t5_rds" {
  cluster_identifier   = "itsag1t5-aurora-cluster"
  engine               = "aurora-mysql"
  engine_version       = "5.7.mysql_aurora.2.07.2"
  skip_final_snapshot  = true
  master_username      = var.rds_username
  master_password      = var.rds_password
  database_name        = "itsag1t5Ascenda"
  db_subnet_group_name = aws_db_subnet_group.itsag1t5_rds_private_subnet_grp.name
  enabled_cloudwatch_logs_exports = [
    "error",
    "general",
    "slowquery",
  ]
}

resource "aws_rds_cluster_instance" "itsag1t5_rds_instance" {
  count                = 2
  cluster_identifier   = aws_rds_cluster.itsag1t5_rds.id
  instance_class       = "db.r4.large"
  db_subnet_group_name = aws_db_subnet_group.itsag1t5_rds_private_subnet_grp.name
  engine               = aws_rds_cluster.itsag1t5_rds.engine
  engine_version       = aws_rds_cluster.itsag1t5_rds.engine_version
}
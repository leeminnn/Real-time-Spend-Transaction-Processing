resource "aws_vpc" "itsag1t5_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    "Name" = "${var.environment_prefix}_vpc"
  }
}

resource "aws_internet_gateway" "itsag1t5_igw" {
  vpc_id = aws_vpc.itsag1t5_vpc.id
  tags = {
    "Name" = "${var.environment_prefix}_igw"
  }
}

resource "aws_subnet" "itsag1t5_public_subnet" {
  vpc_id                  = aws_vpc.itsag1t5_vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.environment_prefix}_${element(var.availability_zones, count.index)}_public_subnet"
  }
}

resource "aws_eip" "itsag1t5_public_nat_eip" {
  count = length(var.availability_zones)
  vpc   = true
  tags = {
    "Name" = "${var.environment_prefix}_public_nat_eip"
  }
}

resource "aws_nat_gateway" "itsag1t5_public_private1_nat_gateway" {
  count         = length(var.public_subnets_cidr)
  allocation_id = element(aws_eip.itsag1t5_public_nat_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.itsag1t5_public_subnet.*.id, count.index)
  tags = {
    "Name" = "${var.environment_prefix}_public_nat_gateway"
  }
  depends_on = [
    aws_internet_gateway.itsag1t5_igw
  ]
}

resource "aws_route_table" "itsag1t5_public_rt" {
  vpc_id = aws_vpc.itsag1t5_vpc.id
  tags = {
    "Name" = "${var.environment_prefix}_public_rt"
  }
}

resource "aws_route" "itsag1t5_public_igw_route" {
  route_table_id         = aws_route_table.itsag1t5_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.itsag1t5_igw.id
}

resource "aws_route_table_association" "itsag1t5_public_rt_association" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.itsag1t5_public_subnet.*.id, count.index)
  route_table_id = aws_route_table.itsag1t5_public_rt.id
}

resource "aws_subnet" "itsag1t5_private_subnet" {
  vpc_id                  = aws_vpc.itsag1t5_vpc.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = {
    "Name" = "${var.environment_prefix}_${element(var.availability_zones, count.index)}_private_subnet"
  }
}

resource "aws_route_table" "itsag1t5_private_rt" {
  count  = length(var.private_subnets_cidr)
  vpc_id = aws_vpc.itsag1t5_vpc.id
  tags = {
    "Name" = "${var.environment_prefix}_${element(var.availability_zones, count.index)}_private_rt"
  }
}

resource "aws_route_table_association" "itsag1t5_private_rt_association" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.itsag1t5_private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.itsag1t5_private_rt.*.id, count.index)
}

resource "aws_route" "itsag1t5_private1_public_route" {
  count                  = length(var.public_subnets_cidr)
  route_table_id         = element(aws_route_table.itsag1t5_private_rt.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.itsag1t5_public_private1_nat_gateway.*.id, count.index)
  depends_on = [
    aws_route_table.itsag1t5_private_rt
  ]
}

resource "aws_network_acl" "itsag1t5_private_acl" {
  vpc_id     = aws_vpc.itsag1t5_vpc.id
  subnet_ids = slice(aws_subnet.itsag1t5_private_subnet.*.id, length(var.availability_zones), length(var.private_subnets_cidr))

  egress {
    action     = "allow"
    cidr_block = "10.0.0.0/16"
    from_port  = 0
    to_port    = 0
    protocol   = -1
    rule_no    = 100
  }

  ingress {
    action     = "allow"
    cidr_block = "10.0.0.0/16"
    from_port  = 0
    to_port    = 0
    protocol   = -1
    rule_no    = 100
  }

  tags = {
    "Name" = "${var.environment_prefix}_private_acl"
  }
}


################################################################################
# API Loadbalancer
################################################################################
resource "aws_alb" "itsag1t5_alb" {
  name               = "${var.environment_prefix}Alb"
  load_balancer_type = "application"
  subnets            = aws_subnet.itsag1t5_public_subnet.*.id
  security_groups    = ["${aws_security_group.itsag1t5_alb_sg.id}"]
}

resource "aws_security_group" "itsag1t5_alb_sg" {
  name        = "${var.environment_prefix}_alb_sg"
  description = "Security group for API loadbalancer"
  vpc_id      = aws_vpc.itsag1t5_vpc.id
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "itsag1t5_frontend_alb" {
  name               = "${var.environment_prefix}FrontendAlb"
  load_balancer_type = "application"
  subnets            = aws_subnet.itsag1t5_public_subnet.*.id
  security_groups    = ["${aws_security_group.itsag1t5_frontend_alb_sg.id}"]
}

resource "aws_security_group" "itsag1t5_frontend_alb_sg" {
  name        = "${var.environment_prefix}_frontend_alb_sg"
  description = "Security group for Frontend loadbalancer"
  vpc_id      = aws_vpc.itsag1t5_vpc.id
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_alb" "itsag1t5_frontend_admin_alb" {
  name               = "${var.environment_prefix}FrontendAdminAlb"
  load_balancer_type = "application"
  subnets            = aws_subnet.itsag1t5_public_subnet.*.id
  security_groups    = ["${aws_security_group.itsag1t5_frontend_admin_alb_sg.id}"]
}

resource "aws_security_group" "itsag1t5_frontend_admin_alb_sg" {
  name        = "${var.environment_prefix}_frontend_admin_alb_sg"
  description = "Security group for Frontend loadbalancer"
  vpc_id      = aws_vpc.itsag1t5_vpc.id
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

################################################################################
# VPC Endpoints
################################################################################

resource "aws_vpc_endpoint" "itsag1t5_ecr_api" {
  vpc_id            = aws_vpc.itsag1t5_vpc.id
  service_name      = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids        = tolist(aws_subnet.itsag1t5_private_subnet.*.id)
  tags = {
    "Name" = "${var.environment_prefix}_ecr_api"
  }
}

resource "aws_vpc_endpoint" "itsag1t5_ecs_dkr" {
  vpc_id            = aws_vpc.itsag1t5_vpc.id
  service_name      = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids        = tolist(aws_subnet.itsag1t5_private_subnet.*.id)
  tags = {
    "Name" = "${var.environment_prefix}_ecr_dkr"
  }
}

resource "aws_vpc_endpoint" "itsag1t5_secret_manager" {
  vpc_id            = aws_vpc.itsag1t5_vpc.id
  service_name      = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids        = tolist(aws_subnet.itsag1t5_private_subnet.*.id)
  tags = {
    "Name" = "${var.environment_prefix}_secretsmanager"
  }
}

resource "aws_vpc_endpoint" "itsag1t5_s3" {
  vpc_id            = aws_vpc.itsag1t5_vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = tolist(aws_route_table.itsag1t5_private_rt.*.id)
  tags = {
    "Name" = "${var.environment_prefix}_s3"
  }
}

################################################################################
# ECR
################################################################################

resource "aws_ecr_repository" "itsag1t5_lambda_exavault_sftp_ecr" {
  name                 = "itsag1t5-lambda-exavault-sftp"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "itsag1t5_campaign_points_processing_ecr" {
  name                 = "itsag1t5-campaign-points-processing"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "itsag1t5_transaction_api_ecr" {
  name                 = "itsag1t5-transaction-api"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "itsag1t5_user_processing_ecr" {
  name                 = "itsag1t5-user-processing"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "itsag1t5_lambda_file_reader_ecr" {
  name                 = "itsag1t5-lambda-file-reader"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "itsag1t5_transaction-points-processing_ecr" {
  name                 = "itsag1t5-transaction-points-processing"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "itsag1t5_user_auth_service_ecr" {
  name                 = "itsag1t5-user-auth-service"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "itsag1t5_frontend_client_ecr" {
  name                 = "itsag1t5-frontend-client"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "itsag1t5_frontend_admin_ecr" {
  name                 = "itsag1t5-frontend-admin"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "itsag1t5_backend_admin_ecr" {
  name                 = "itsag1t5-backend-admin"
  image_tag_mutability = "MUTABLE"
}
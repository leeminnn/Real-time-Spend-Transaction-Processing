locals {
  rds_url = "mysql://${var.rds_credential_string.username}:${var.rds_credential_string.password}@${var.rds_rr_endpoint}:3306/${var.rds_database_name}"
}

resource "aws_ecs_cluster" "itsag1t5_ecs_cluster" {
  name = "itsag1t5-ecs-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "itsag1t5_ecs_cluster_providers" {
  cluster_name       = aws_ecs_cluster.itsag1t5_ecs_cluster.name
  capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}


###############################################################################
# Secrets
###############################################################################

resource "aws_secretsmanager_secret" "processing_service_secret" {
  name                           = "itsag1t5-processing-services-database-secret"
  recovery_window_in_days        = 0
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "processing_service_secret_value" {
  secret_id = aws_secretsmanager_secret.processing_service_secret.id
  secret_string = jsonencode({
    "username" : "${var.rds_master_username}",
    "password" : "${var.rds_master_password}",
    "host" : "${var.rds_writer_endpoint}",
    "port" : 3306,
    "dbname" : "${var.rds_database_name}",
    "dbClusterIdentifier" : "itsag1t5-aurora-cluster",
  })
}


###############################################################################
# Fargate Task Definition
###############################################################################

resource "aws_ecs_task_definition" "itsag1t5_user_auth_service" {
  family = "itsag1t5-user-auth-service"
  container_definitions = jsonencode([
    {
      name      = "itsag1t5-user-auth-service",
      image     = "${data.aws_ecr_repository.itsag1t5_user_auth_service_ecr.repository_url}:latest",
      cpu       = 256,
      memory    = 512,
      essential = true,
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80,
          protocol      = "tcp"
        }
      ],
      environment = [
        {
          name  = "RDS_DATABASE_URL",
          value = "${local.rds_url}"
        },
        {
          name  = "JWT_SECRET",
          value = "${var.jwt_secret}"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.itsag1t5_user_auth_service_log_group.name}",
          awslogs-region        = "${var.region}",
          awslogs-stream-prefix = "ecs"
        }
      }
    },
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.itsag1t5_user_auth_service.arn
  task_role_arn            = aws_iam_role.itsag1t5_user_auth_service.arn
}

resource "aws_ecs_task_definition" "itsag1t5_campaign_service" {
  family = "itsag1t5-campaign-service"
  container_definitions = jsonencode([
    {
      name      = "itsag1t5-campaign-service",
      image     = "${data.aws_ecr_repository.itsag1t5_backend_admin_ecr.repository_url}:latest",
      cpu       = 256,
      memory    = 512,
      essential = true,
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80,
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.itsag1t5_campaign_service_log_group.name}",
          awslogs-region        = "${var.region}",
          awslogs-stream-prefix = "ecs"
        }
      }
    },
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.itsag1t5_campaign_service.arn
  task_role_arn            = aws_iam_role.itsag1t5_campaign_service.arn
}

resource "aws_ecs_task_definition" "itsag1t5_frontend_client_service" {
  family = "itsag1t5-frontend-client-service"
  container_definitions = jsonencode([
    {
      name      = "itsag1t5-frontend-client-service",
      image     = "${data.aws_ecr_repository.itsag1t5_frontend_client_ecr.repository_url}:latest",
      cpu       = 256,
      memory    = 512,
      essential = true,
      portMappings = [
        {
          containerPort = 3000,
          hostPort      = 3000,
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.itsag1t5_frontend_client_service_log_group.name}",
          awslogs-region        = "${var.region}",
          awslogs-stream-prefix = "ecs"
        }
      }
    },
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.itsag1t5_frontend_service.arn
  task_role_arn            = aws_iam_role.itsag1t5_frontend_service.arn
}

resource "aws_ecs_task_definition" "itsag1t5_frontend_admin_service" {
  family = "itsag1t5-frontend-admin-service"
  container_definitions = jsonencode([
    {
      name      = "itsag1t5-frontend-admin-service",
      image     = "${data.aws_ecr_repository.itsag1t5_frontend_admin_ecr.repository_url}:latest",
      cpu       = 256,
      memory    = 512,
      essential = true,
      portMappings = [
        {
          containerPort = 3000,
          hostPort      = 3000,
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.itsag1t5_frontend_admin_service_log_group.name}",
          awslogs-region        = "${var.region}",
          awslogs-stream-prefix = "ecs"
        }
      }
    },
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.itsag1t5_frontend_service.arn
  task_role_arn            = aws_iam_role.itsag1t5_frontend_service.arn
}

resource "aws_ecs_task_definition" "itsag1t5_campaign_points_processing" {
  family = "itsag1t5-campaign-points-processing"
  container_definitions = jsonencode([
    {
      name      = "itsag1t5-campaign-points-processing",
      image     = "${data.aws_ecr_repository.itsag1t5_campaign_points_processing_ecr.repository_url}:latest",
      cpu       = 1024,
      memory    = 2048,
      essential = true,
      environment = [
        {
          name  = "SECRET_ID",
          value = "${aws_secretsmanager_secret.processing_service_secret.id}"
        },
        {
          name  = "SQS_QUEUE_URL",
          value = "${var.sqs_campaign_url}"
        },
        {
          name  = "USER_SQS_QUEUE_URL",
          value = "${var.sqs_user_url}"
        },
        {
          name  = "REGION",
          value = "${var.region}"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.itsag1t5_campaign_points_processing_log_group.name}",
          awslogs-region        = "${var.region}",
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 2048
  cpu                      = 1024
  execution_role_arn       = aws_iam_role.itsag1t5_campaign_points_processing.arn
  task_role_arn            = aws_iam_role.itsag1t5_campaign_points_processing.arn
}

resource "aws_ecs_task_definition" "itsag1t5_transaction_processing" {
  family = "itsag1t5-transaction-points-processing"
  container_definitions = jsonencode([
    {
      name      = "itsag1t5-transaction-points-processing",
      image     = "${data.aws_ecr_repository.itsag1t5_transaction_points_processing_ecr.repository_url}:latest",
      cpu       = 1024,
      memory    = 2048,
      essential = true,
      environment = [
        {
          name  = "secret_id",
          value = "${aws_secretsmanager_secret.processing_service_secret.id}"
        },
        {
          name  = "SQS_QUEUE_URL",
          value = "${var.sqs_transaction_url}"
        },
        {
          name  = "USER_SQS_QUEUE_URL",
          value = "${var.sqs_user_url}"
        },
        {
          name  = "REGION",
          value = "${var.region}"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.itsag1t5_transaction_points_processing_log_group.name}",
          awslogs-region        = "${var.region}",
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 2048
  cpu                      = 1024
  execution_role_arn       = aws_iam_role.itsag1t5_campaign_points_processing.arn
  task_role_arn            = aws_iam_role.itsag1t5_campaign_points_processing.arn
}

resource "aws_ecs_task_definition" "itsag1t5_user_processing" {
  family = "itsag1t5-user-processing"
  container_definitions = jsonencode([
    {
      name      = "itsag1t5-user-processing",
      image     = "${data.aws_ecr_repository.itsag1t5_user_processing_ecr.repository_url}:latest",
      cpu       = 1024,
      memory    = 2048,
      essential = true,
      environment = [
        {
          name  = "SECRET_ID",
          value = "${aws_secretsmanager_secret.processing_service_secret.id}"
        },
        {
          name  = "SQS_QUEUE_URL",
          value = "${var.sqs_user_url}"
        },
        {
          name  = "REGION",
          value = "${var.region}"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.itsag1t5_user_processing_log_group.name}",
          awslogs-region        = "${var.region}",
          awslogs-stream-prefix = "ecs"
        }
      }
    },
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.itsag1t5_campaign_points_processing.arn
  task_role_arn            = aws_iam_role.itsag1t5_campaign_points_processing.arn
}

###############################################################################
# Service Initiation
###############################################################################
resource "aws_ecs_service" "itsag1t5_user_auth_service" {
  name            = "itsag1t5-user-auth-service"
  cluster         = aws_ecs_cluster.itsag1t5_ecs_cluster.id
  task_definition = aws_ecs_task_definition.itsag1t5_user_auth_service.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.itsag1t5_user_auth_service_tg.arn
    container_name   = aws_ecs_task_definition.itsag1t5_user_auth_service.family
    container_port   = 80
  }

  network_configuration {
    subnets          = var.public_subnets
    assign_public_ip = true
    security_groups = [
      aws_security_group.itsag1t5_service_api_sg.id
    ]
  }
  depends_on = [
    aws_ecs_task_definition.itsag1t5_user_auth_service
  ]
}

resource "aws_ecs_service" "itsag1t5_frontend_client_service" {
  name            = "itsag1t5-frontend-client-service"
  cluster         = aws_ecs_cluster.itsag1t5_ecs_cluster.id
  task_definition = aws_ecs_task_definition.itsag1t5_frontend_client_service.arn
  desired_count   = 2
  launch_type     = "FARGATE"


  load_balancer {
    target_group_arn = aws_lb_target_group.itsag1t5_frontend_client_service_tg.arn
    container_name   = aws_ecs_task_definition.itsag1t5_frontend_client_service.family
    container_port   = 3000
  }

  network_configuration {
    subnets          = var.public_subnets
    assign_public_ip = true
    security_groups = [
      aws_security_group.itsag1t5_fec_alb_sg.id
    ]
  }
  depends_on = [
    aws_ecs_task_definition.itsag1t5_frontend_client_service
  ]
}

resource "aws_ecs_service" "itsag1t5_frontend_admin_service" {
  name            = "itsag1t5-frontend-admin-service"
  cluster         = aws_ecs_cluster.itsag1t5_ecs_cluster.id
  task_definition = aws_ecs_task_definition.itsag1t5_frontend_admin_service.arn
  desired_count   = 2
  launch_type     = "FARGATE"


  load_balancer {
    target_group_arn = aws_lb_target_group.itsag1t5_frontend_admin_service_tg.arn
    container_name   = aws_ecs_task_definition.itsag1t5_frontend_admin_service.family
    container_port   = 3000
  }

  network_configuration {
    subnets          = var.public_subnets
    assign_public_ip = true
    security_groups = [
      aws_security_group.itsag1t5_fea_alb_sg.id
    ]
  }
  depends_on = [
    aws_ecs_task_definition.itsag1t5_frontend_admin_service
  ]
}

resource "aws_ecs_service" "itsag1t5_campaign_service" {
  name            = "itsag1t5-campaign-service"
  cluster         = aws_ecs_cluster.itsag1t5_ecs_cluster.id
  task_definition = aws_ecs_task_definition.itsag1t5_campaign_service.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.itsag1t5_campaign_service_tg.arn
    container_name   = aws_ecs_task_definition.itsag1t5_campaign_service.family
    container_port   = 80
  }

  network_configuration {
    subnets          = var.public_subnets
    assign_public_ip = true
    security_groups = [
      aws_security_group.itsag1t5_service_api_sg.id
    ]
  }
  depends_on = [
    aws_ecs_task_definition.itsag1t5_campaign_service
  ]
}

resource "aws_ecs_service" "itsag1t5_campaign_points_processing" {
  name            = "itsag1t5-campaign-points-processing"
  cluster         = aws_ecs_cluster.itsag1t5_ecs_cluster.id
  task_definition = aws_ecs_task_definition.itsag1t5_campaign_points_processing.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    assign_public_ip = false
    security_groups = [
      aws_security_group.itsag1t5_processing_sg.id
    ]
  }
  depends_on = [
    aws_ecs_task_definition.itsag1t5_campaign_points_processing
  ]
}

resource "aws_ecs_service" "itsag1t5_transaction_processing" {
  name            = "itsag1t5-transaction-points-processing"
  cluster         = aws_ecs_cluster.itsag1t5_ecs_cluster.id
  task_definition = aws_ecs_task_definition.itsag1t5_transaction_processing.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    assign_public_ip = false
    security_groups = [
      aws_security_group.itsag1t5_processing_sg.id
    ]
  }
  depends_on = [
    aws_ecs_task_definition.itsag1t5_transaction_processing
  ]
}

resource "aws_ecs_service" "itsag1t5_user_processing" {
  name            = "itsag1t5-user-processing"
  cluster         = aws_ecs_cluster.itsag1t5_ecs_cluster.id
  task_definition = aws_ecs_task_definition.itsag1t5_user_processing.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    assign_public_ip = false
    security_groups = [
      aws_security_group.itsag1t5_processing_sg.id
    ]
  }
  depends_on = [
    aws_ecs_task_definition.itsag1t5_user_processing
  ]
}

###############################################################################
# Auto Scaling
###############################################################################
# User Queue 0 Messages
resource "aws_cloudwatch_metric_alarm" "user_queue_empty" {
  alarm_name          = "user_queue_empty"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "User queue empty"
  dimensions = {
    "QueueName" = "${var.sqs_user_name}"
  }
  alarm_actions = [
    "${aws_appautoscaling_policy.user_processing_scale_down_policy.arn}",
    "${aws_appautoscaling_policy.transaction_processing_scale_up_policy.arn}",
    "${aws_appautoscaling_policy.campaign_points_processing_scale_up_policy.arn}"
  ]
}

# User Queue have message
resource "aws_cloudwatch_metric_alarm" "user_queue_have_message" {
  alarm_name          = "user_queue_have_message"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "User queue have message"
  dimensions = {
    "QueueName" = "${var.sqs_user_name}"
  }
  alarm_actions = [
    "${aws_appautoscaling_policy.transaction_processing_scale_down_policy.arn}",
    "${aws_appautoscaling_policy.campaign_points_processing_scale_down_policy.arn}",
    "${aws_appautoscaling_policy.user_processing_scale_up_policy.arn}"
  ]
}

# User Processing Scaling Up Policy
resource "aws_appautoscaling_policy" "user_processing_scale_up_policy" {
  name = "user_processing_scale_up_policy"
  depends_on = [
    aws_appautoscaling_target.user_processing_target
  ]
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.itsag1t5_ecs_cluster.name}/${aws_ecs_service.itsag1t5_user_processing.name}"
  scalable_dimension = aws_appautoscaling_target.user_processing_target.scalable_dimension
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 10
    metric_aggregation_type = "Average"
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 5
    }
  }
}

# User Processing Scaling Down Policy
resource "aws_appautoscaling_policy" "user_processing_scale_down_policy" {
  name = "user_processing_scale_down_policy"
  depends_on = [
    aws_appautoscaling_target.user_processing_target
  ]
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.itsag1t5_ecs_cluster.name}/${aws_ecs_service.itsag1t5_user_processing.name}"
  scalable_dimension = aws_appautoscaling_target.user_processing_target.scalable_dimension
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 10
    metric_aggregation_type = "Average"
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -5
    }
  }
}

# User Processing Target
resource "aws_appautoscaling_target" "user_processing_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.itsag1t5_ecs_cluster.name}/${aws_ecs_service.itsag1t5_user_processing.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 1
  max_capacity       = 86
}

# Transaction Processing Scaling Up Policy
resource "aws_appautoscaling_policy" "transaction_processing_scale_up_policy" {
  name = "transaction_processing_scale_up_policy"
  depends_on = [
    aws_appautoscaling_target.transaction_processing_target
  ]
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.itsag1t5_ecs_cluster.name}/${aws_ecs_service.itsag1t5_transaction_processing.name}"
  scalable_dimension = aws_appautoscaling_target.transaction_processing_target.scalable_dimension
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 10
    metric_aggregation_type = "Average"
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 5
    }
  }
}

# Transaction Processing Scaling Down Policy
resource "aws_appautoscaling_policy" "transaction_processing_scale_down_policy" {
  name = "transaction_processing_scale_down_policy"
  depends_on = [
    aws_appautoscaling_target.transaction_processing_target
  ]
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.itsag1t5_ecs_cluster.name}/${aws_ecs_service.itsag1t5_transaction_processing.name}"
  scalable_dimension = aws_appautoscaling_target.transaction_processing_target.scalable_dimension
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 10
    metric_aggregation_type = "Average"
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -5
    }
  }
}

# Transaction Processing Scaling Target
resource "aws_appautoscaling_target" "transaction_processing_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.itsag1t5_ecs_cluster.name}/${aws_ecs_service.itsag1t5_transaction_processing.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 1
  max_capacity       = 41
}

# Campaign Points Processing Scaling Up Policy
resource "aws_appautoscaling_policy" "campaign_points_processing_scale_up_policy" {
  name = "campaign_points_processing_scale_up_policy"
  depends_on = [
    aws_appautoscaling_target.campaign_points_processing_target
  ]
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.itsag1t5_ecs_cluster.name}/${aws_ecs_service.itsag1t5_campaign_points_processing.name}"
  scalable_dimension = aws_appautoscaling_target.campaign_points_processing_target.scalable_dimension
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 10
    metric_aggregation_type = "Average"
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 5
    }
  }
}

# Campaign Points Processing Scaling Down Policy
resource "aws_appautoscaling_policy" "campaign_points_processing_scale_down_policy" {
  name = "campaign_points_processing_scale_down_policy"
  depends_on = [
    aws_appautoscaling_target.campaign_points_processing_target
  ]
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.itsag1t5_ecs_cluster.name}/${aws_ecs_service.itsag1t5_campaign_points_processing.name}"
  scalable_dimension = aws_appautoscaling_target.campaign_points_processing_target.scalable_dimension
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 10
    metric_aggregation_type = "Average"
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -5
    }
  }
}

# Campaign Points Processing Scaling Target
resource "aws_appautoscaling_target" "campaign_points_processing_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.itsag1t5_ecs_cluster.name}/${aws_ecs_service.itsag1t5_campaign_points_processing.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 1
  max_capacity       = 41
}

###############################################################################
# Security Group
###############################################################################

resource "aws_security_group" "itsag1t5_service_api_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${data.aws_security_group.itsag1t5_alb_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "itsag1t5_fec_alb_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${data.aws_security_group.itsag1t5_frontend_alb_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "itsag1t5_fea_alb_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${data.aws_security_group.itsag1t5_frontend_admin_alb_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "itsag1t5_processing_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###############################################################################
# ACM & ALB Target Group and Listener
###############################################################################



data "aws_acm_certificate" "frontend_client_cert" {
  domain = "itsag1t5.com"
}



resource "aws_lb_target_group" "itsag1t5_user_auth_service_tg" {
  name        = "itsag1t5-user-auth-service-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    matcher = "200,301,302"
    path    = "/auth/healthcheck"
  }
}

resource "aws_lb_listener" "itsag1t5_user_auth_service_listener" {
  load_balancer_arn = data.aws_lb.itsag1t5_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.frontend_client_cert.arn
  default_action {
    target_group_arn = aws_lb_target_group.itsag1t5_user_auth_service_tg.arn
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "itsag1t5_redirect_user_auth" {
  listener_arn = aws_lb_listener.itsag1t5_user_auth_service_listener.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.itsag1t5_user_auth_service_tg.arn
  }

  condition {
    path_pattern {
      values = [
        "/user/*",
        "/auth/*"
      ]
    }
  }
}

resource "aws_lb_target_group" "itsag1t5_campaign_service_tg" {
  name        = "itsag1t5-campaign-service-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    matcher = "200,301,302"
    path    = "/campaign/healthcheck"
  }
}

resource "aws_lb_listener_rule" "itsag1t5_redirect_campaign" {
  listener_arn = aws_lb_listener.itsag1t5_user_auth_service_listener.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.itsag1t5_campaign_service_tg.arn
  }

  condition {
    path_pattern {
      values = [
        "/campaign/*"
      ]
    }
  }
}

resource "aws_lb_target_group" "itsag1t5_frontend_client_service_tg" {
  name        = "itsag1t5-fe-client-service-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    matcher = "200,301,302"
    path    = "/api/healthcheck"
  }
}

resource "aws_lb_listener" "itsag1t5_frontend_client_service_listener" {
  load_balancer_arn = data.aws_lb.itsag1t5_frontend_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.frontend_client_cert.arn
  default_action {
    target_group_arn = aws_lb_target_group.itsag1t5_frontend_client_service_tg.arn
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "itsag1t5_redirect_frontend_client" {
  listener_arn = aws_lb_listener.itsag1t5_frontend_client_service_listener.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.itsag1t5_frontend_client_service_tg.arn
  }

  condition {
    path_pattern {
      values = [
        "/*"
      ]
    }
  }
}

resource "aws_lb_target_group" "itsag1t5_frontend_admin_service_tg" {
  name        = "itsag1t5-fe-admin-service-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    matcher = "200,301,302"
    path    = "/api/healthcheck"
  }
}

resource "aws_lb_listener" "itsag1t5_frontend_admin_service_listener" {
  load_balancer_arn = data.aws_lb.itsag1t5_frontend_admin_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.frontend_client_cert.arn
  default_action {
    target_group_arn = aws_lb_target_group.itsag1t5_frontend_admin_service_tg.arn
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "itsag1t5_redirect_frontend_admin" {
  listener_arn = aws_lb_listener.itsag1t5_frontend_admin_service_listener.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.itsag1t5_frontend_admin_service_tg.arn
  }

  condition {
    path_pattern {
      values = [
        "/*"
      ]
    }
  }
}

###############################################################################
# IAM Role
###############################################################################
### User Auth Service
resource "aws_iam_role" "itsag1t5_user_auth_service" {
  name               = "itsag1t5-user-auth-service"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "itsag1t5_uas_ecs_taskexecution_role_attachment" {
  role       = aws_iam_role.itsag1t5_user_auth_service.id
  policy_arn = data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn
}

resource "aws_iam_role" "itsag1t5_frontend_service" {
  name               = "itsag1t5-frontend-service"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "itsag1t5_frontend_ecs_taskexecution_role_attachment" {
  role       = aws_iam_role.itsag1t5_frontend_service.id
  policy_arn = data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn
}

resource "aws_iam_role" "itsag1t5_campaign_service" {
  name               = "itsag1t5-campaign-service"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "itsag1t5_cs_ecs_taskexecution_role_attachment" {
  role       = aws_iam_role.itsag1t5_campaign_service.id
  policy_arn = data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn
}


resource "aws_iam_role_policy_attachment" "itsag1t5_cs_dynamodb_fa_role_attachment" {
  role       = aws_iam_role.itsag1t5_campaign_service.id
  policy_arn = data.aws_iam_policy.AmazonDynamoDBFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "itsag1t5_cs_s3fa_role_attachment" {
  role       = aws_iam_role.itsag1t5_campaign_service.id
  policy_arn = data.aws_iam_policy.AWSS3FullAccess.arn
}

### Campaign Points Processing
resource "aws_iam_role" "itsag1t5_campaign_points_processing" {
  name               = "itsag1t5-campaign-points-processing-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "itsag1t5_cpp_ecs_taskexecution_role_attachment" {
  role       = aws_iam_role.itsag1t5_campaign_points_processing.id
  policy_arn = data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn
}

resource "aws_iam_role_policy_attachment" "itsag1t5_cpp_secretmanager_role_attachment" {
  role       = aws_iam_role.itsag1t5_campaign_points_processing.id
  policy_arn = data.aws_iam_policy.SecretsManagerReadWrite.arn
}

resource "aws_iam_role_policy_attachment" "itsag1t5_cpp_rds_role_attachment" {
  role       = aws_iam_role.itsag1t5_campaign_points_processing.id
  policy_arn = data.aws_iam_policy.AmazonRDSDataFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "itsag1t5_cpp_ecs_role_attachment" {
  role       = aws_iam_role.itsag1t5_campaign_points_processing.id
  policy_arn = data.aws_iam_policy.AmazonECSFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "itsag1t5_cpp_sqs_role_attachment" {
  role       = aws_iam_role.itsag1t5_campaign_points_processing.id
  policy_arn = data.aws_iam_policy.AWSLambdaSQSQueueExecutionRole.arn
}

resource "aws_iam_role_policy_attachment" "itsag1t5_cpp_sns_role_attachment" {
  role       = aws_iam_role.itsag1t5_campaign_points_processing.id
  policy_arn = data.aws_iam_policy.AmazonSNSFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "itsag1t5_cpp_dynamodb_ro_role_attachment" {
  role       = aws_iam_role.itsag1t5_campaign_points_processing.id
  policy_arn = data.aws_iam_policy.AmazonDynamoDBReadOnlyAccess.arn
}


###############################################################################
# Cloudwatch Log Group
###############################################################################
resource "aws_cloudwatch_log_group" "itsag1t5_user_auth_service_log_group" {
  name = "itsag1t5-user-auth-service"
}

resource "aws_cloudwatch_log_group" "itsag1t5_campaign_points_processing_log_group" {
  name = "itsag1t5-campaign-points-processing"
}

resource "aws_cloudwatch_log_group" "itsag1t5_transaction_points_processing_log_group" {
  name = "itsag1t5-transaction-points-processing"
}

resource "aws_cloudwatch_log_group" "itsag1t5_user_processing_log_group" {
  name = "itsag1t5-user-processing"
}

resource "aws_cloudwatch_log_group" "itsag1t5_campaign_service_log_group" {
  name = "itsag1t5-campaign-service"
}

resource "aws_cloudwatch_log_group" "itsag1t5_frontend_admin_service_log_group" {
  name = "itsag1t5-frontend-admin-service"
}

resource "aws_cloudwatch_log_group" "itsag1t5_frontend_client_service_log_group" {
  name = "itsag1t5-frontend-client-service"
}

###############################################################################
# IAM Policy
###############################################################################
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy" "SecretsManagerReadWrite" {
  arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

data "aws_iam_policy" "AmazonRDSDataFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"
}

data "aws_iam_policy" "AmazonECSFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

data "aws_iam_policy" "AWSLambdaSQSQueueExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

data "aws_iam_policy" "AmazonSNSFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

data "aws_iam_policy" "AmazonDynamoDBReadOnlyAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
}

data "aws_iam_policy" "AmazonDynamoDBFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

data "aws_iam_policy" "AWSS3FullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

###############################################################################
# ECR Repository
###############################################################################
data "aws_ecr_repository" "itsag1t5_user_auth_service_ecr" {
  name = "itsag1t5-user-auth-service"
}

data "aws_ecr_repository" "itsag1t5_campaign_points_processing_ecr" {
  name = "itsag1t5-campaign-points-processing"
}

data "aws_ecr_repository" "itsag1t5_transaction_points_processing_ecr" {
  name = "itsag1t5-transaction-points-processing"
}

data "aws_ecr_repository" "itsag1t5_user_processing_ecr" {
  name = "itsag1t5-user-processing"
}


data "aws_ecr_repository" "itsag1t5_backend_admin_ecr" {
  name = "itsag1t5-backend-admin"
}

data "aws_ecr_repository" "itsag1t5_frontend_client_ecr" {
  name = "itsag1t5-frontend-client"
}

data "aws_ecr_repository" "itsag1t5_frontend_admin_ecr" {
  name = "itsag1t5-frontend-admin"
}


###############################################################################
# API Load Balancer
###############################################################################
data "aws_lb" "itsag1t5_alb" {
  name = "${var.environment_prefix}Alb"
}

data "aws_security_group" "itsag1t5_alb_sg" {
  name = "${var.environment_prefix}_alb_sg"
}

data "aws_lb" "itsag1t5_frontend_alb" {
  name = "${var.environment_prefix}FrontendAlb"
}

data "aws_security_group" "itsag1t5_frontend_alb_sg" {
  name = "${var.environment_prefix}_frontend_alb_sg"
}


data "aws_lb" "itsag1t5_frontend_admin_alb" {
  name = "${var.environment_prefix}FrontendAdminAlb"
}

data "aws_security_group" "itsag1t5_frontend_admin_alb_sg" {
  name = "${var.environment_prefix}_frontend_admin_alb_sg"
}

###############################################################################
# VPC
###############################################################################
data "aws_vpc" "itsag1t5_vpc" {
  id = var.vpc_id
}

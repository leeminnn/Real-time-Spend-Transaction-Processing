data "aws_iam_policy" "SecretsManagerReadWrite" {
  arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

data "aws_iam_policy" "AmazonS3FullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "AmazonSQSFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

data "aws_iam_policy" "AmazonSNSFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

# Exavault SFTP

resource "aws_s3_bucket" "sftp_staging" {
  bucket        = "itsag1t5-sftp-staging"
  force_destroy = true
}

resource "aws_s3_bucket" "exavault_lsd" {
  bucket        = "itsag1t5-exavault-lsd"
  force_destroy = true
}

resource "aws_s3_bucket" "proceesed_data" {
  bucket        = "itsag1t5-processed-data"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "processed_data_lifecycle" {
  bucket = aws_s3_bucket.proceesed_data.id
  rule {
    id      = "processed_data_lifecycle"
    status  = "Enabled"
    transition {
      days          = 30
      storage_class = "GLACIER"
    }
  }
}

resource "aws_secretsmanager_secret" "exavault_credentials_secret" {
  name                           = "itsag1t5_exavault_sftp"
  recovery_window_in_days        = 0
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "exavault_credentials_value" {
  secret_id     = aws_secretsmanager_secret.exavault_credentials_secret.id
  secret_string = jsonencode(var.exavault_credential_string)
}

data "aws_ecr_repository" "exavault_sftp" {
  name = "itsag1t5-lambda-exavault-sftp"
}

data "aws_ecr_image" "exavault_sftp" {
  repository_name = "itsag1t5-lambda-exavault-sftp"
  image_tag       = "latest"
}

resource "aws_iam_role" "exavault_sftp_iam" {
  name = "itsag1t5-lambda-exavault-sftp-iam"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "exavault_sftp_iam_AmazonS3FullAccess_attach" {
  role       = aws_iam_role.exavault_sftp_iam.name
  policy_arn = data.aws_iam_policy.AmazonS3FullAccess.arn
}

resource "aws_iam_role_policy_attachment" "exavault_sftp_iam_SecretsManagerReadWrite_attach" {
  role       = aws_iam_role.exavault_sftp_iam.name
  policy_arn = data.aws_iam_policy.SecretsManagerReadWrite.arn
}

resource "aws_iam_role_policy_attachment" "exavault_sftp_iam_AWSLambdaBasicExecutionRole_attach" {
  role       = aws_iam_role.exavault_sftp_iam.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}

resource "aws_lambda_function" "exavault_sftp" {
  function_name = "itsag1t5-exavault-sftp"
  role          = aws_iam_role.exavault_sftp_iam.arn
  architectures = ["x86_64"]
  package_type  = "Image"
  image_uri     = "${data.aws_ecr_repository.exavault_sftp.repository_url}@${data.aws_ecr_image.exavault_sftp.id}"
  memory_size   = 3072
  timeout       = 300
  environment {
    variables = {
      "SECRET_ARN" = aws_secretsmanager_secret.exavault_credentials_secret.arn
    }
  }
}


resource "aws_cloudwatch_event_rule" "exavault_sftp_event_rule" {
  name                = "exavault-sftp-event-rule"
  schedule_expression = "cron(0 16 * * ? *)"
}

resource "aws_cloudwatch_event_target" "exavault_sftp_event_target" {
  rule = aws_cloudwatch_event_rule.exavault_sftp_event_rule.name
  arn  = aws_lambda_function.exavault_sftp.arn
  input= jsonencode({
    "test" = "hello"
  })
}

resource "aws_lambda_permission" "exavault_sftp_function_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.exavault_sftp.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.exavault_sftp_event_rule.arn
}

# File Reader
data "aws_ecr_repository" "file_reader" {
  name = "itsag1t5-lambda-file-reader"
}

data "aws_ecr_image" "file_reader" {
  repository_name = "itsag1t5-lambda-file-reader"
  image_tag       = "latest"
}

resource "aws_iam_role" "file_reader_iam" {
  name = "itsag1t5-lambda-file-reader-iam"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "file_reader_iam_AWSLambdaBasicExecutionRole_attach" {
  role       = aws_iam_role.file_reader_iam.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}

resource "aws_iam_role_policy_attachment" "file_reader_iam_AmazonS3FullAccess_attach" {
  role       = aws_iam_role.file_reader_iam.name
  policy_arn = data.aws_iam_policy.AmazonS3FullAccess.arn
}

resource "aws_iam_role_policy_attachment" "file_reader_iam_AmazonSQSFullAccess_attach" {
  role = aws_iam_role.file_reader_iam.name
  policy_arn = data.aws_iam_policy.AmazonSQSFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "file_reader_iam_AmazonSNSFullAccess_attach" {
  role = aws_iam_role.file_reader_iam.name
  policy_arn = data.aws_iam_policy.AmazonSNSFullAccess.arn
}

resource "aws_lambda_function" "file_reader" {
  function_name = "itsag1t5-file-reader"
  role          = aws_iam_role.file_reader_iam.arn
  architectures = ["x86_64"]
  package_type  = "Image"
  image_uri     = "${data.aws_ecr_repository.file_reader.repository_url}@${data.aws_ecr_image.file_reader.id}"
  memory_size = 3072
  timeout = 900
  reserved_concurrent_executions = 5
  environment {
    variables = {
      "PROCESSED_BUCKET" = aws_s3_bucket.proceesed_data.bucket
      "SNS_TOPIC_ARN" = var.transaction_sns_topic_arn
      "SQS_QUEUE" = var.user_sqs
    }
  }
}

resource "aws_lambda_permission" "file_reader" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_reader.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.sftp_staging.arn
}

resource "aws_s3_bucket_notification" "staging_bucket_noti" {
  bucket = aws_s3_bucket.sftp_staging.bucket
  lambda_function {
      lambda_function_arn = aws_lambda_function.file_reader.arn
      events = ["s3:ObjectCreated:*"]
  }
}
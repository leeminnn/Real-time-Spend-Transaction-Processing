data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "itsag1t5_transaction_sns_policy_document" {
  policy_id = "__default_policy_ID"
  statement {
    sid    = "__default_statement_ID"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "SNS:Publish",
      "SNS:RemovePermission",
      "SNS:SetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:AddPermission",
      "SNS:Subscribe"
    ]
    resources = [
      aws_sns_topic.itsag1t5_transaction_sns.arn
    ]
    condition {
      test = "StringEquals"

      variable = "AWS:SourceOwner"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
  statement {
    sid    = "__console_pub_0"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "SNS:Publish"
    ]
    resources = [
      aws_sns_topic.itsag1t5_transaction_sns.arn
    ]
  }
  statement {
    sid    = "__console_sub_0"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "SNS:Subscribe"
    ]
    resources = [
      aws_sns_topic.itsag1t5_transaction_sns.arn
    ]
  }
}


data "aws_iam_policy_document" "itsag1t5_transaction_sqs_policy_document" {
  policy_id = "__default_policy_ID"
  statement {
    sid    = "__owner_statement"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id
      ]
    }
    actions = [
      "SQS:*"
    ]
    resources = [
      aws_sqs_queue.itsag1t5_transaction_sqs.arn
    ]
  }
  statement {
    sid    = "topic-subscription-arn:${aws_sns_topic.itsag1t5_transaction_sns.arn}"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "SQS:SendMessage"
    ]
    resources = [
      aws_sqs_queue.itsag1t5_transaction_sqs.arn
    ]
    condition {
      test = "ArnLike"
      values = [
        aws_sns_topic.itsag1t5_transaction_sns.arn
      ]
      variable = "AWS:SourceArn"
    }
  }
}

data "aws_iam_policy_document" "itsag1t5_campaign_sqs_policy_document" {
  policy_id = "__default_policy_ID"
  statement {
    sid    = "__owner_statement"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id
      ]
    }
    actions = [
      "SQS:*"
    ]
    resources = [
      aws_sqs_queue.itsag1t5_campaign_sqs.arn
    ]
  }
  statement {
    sid    = "topic-subscription-arn:${aws_sns_topic.itsag1t5_transaction_sns.arn}"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "SQS:SendMessage"
    ]
    resources = [
      aws_sqs_queue.itsag1t5_campaign_sqs.arn
    ]
    condition {
      test = "ArnLike"
      values = [
        aws_sns_topic.itsag1t5_transaction_sns.arn
      ]
      variable = "AWS:SourceArn"
    }
  }
}

resource "aws_sns_topic" "itsag1t5_transaction_sns" {
  name                        = "itsag1t5-transaction-sns.fifo"
  fifo_topic                  = true
  content_based_deduplication = true
}

resource "aws_sns_topic_policy" "itsag1t5_transaction_sns_policy" {
  arn    = aws_sns_topic.itsag1t5_transaction_sns.arn
  policy = data.aws_iam_policy_document.itsag1t5_transaction_sns_policy_document.json
}

resource "aws_sqs_queue" "itsag1t5_transaction_sqs" {
  name                        = "itsag1t5_transaction_sqs.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  deduplication_scope   = "messageGroup"
  fifo_throughput_limit = "perMessageGroupId"
}

resource "aws_sns_topic_subscription" "itsag1t5_transaction_sqs_sns_subscription" {
  topic_arn = aws_sns_topic.itsag1t5_transaction_sns.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.itsag1t5_transaction_sqs.arn
}

resource "aws_sqs_queue_policy" "itsag1t5_transaction_sqs_policy" {
  queue_url = aws_sqs_queue.itsag1t5_transaction_sqs.url
  policy    = data.aws_iam_policy_document.itsag1t5_transaction_sqs_policy_document.json
}

resource "aws_sqs_queue" "itsag1t5_campaign_sqs" {
  name                        = "itsag1t5_campaign_sqs.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  deduplication_scope   = "messageGroup"
  fifo_throughput_limit = "perMessageGroupId"
}

resource "aws_sqs_queue_policy" "itsag1t5_campaign_sqs_policy" {
  queue_url = aws_sqs_queue.itsag1t5_campaign_sqs.url
  policy    = data.aws_iam_policy_document.itsag1t5_campaign_sqs_policy_document.json
}

resource "aws_sns_topic_subscription" "itsag1t5_campaign_sqs_sns_subscription" {
  topic_arn = aws_sns_topic.itsag1t5_transaction_sns.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.itsag1t5_campaign_sqs.arn
}


# User SQS
data "aws_iam_policy_document" "itsag1t5_user_sqs_policy_document" {
  policy_id = "__default_policy_ID"
  statement {
    sid    = "__owner_statement"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id
      ]
    }
    actions = [
      "SQS:*"
    ]
    resources = [
      aws_sqs_queue.itsag1t5_user_processing_sqs.arn
    ]
  }
}

resource "aws_sqs_queue" "itsag1t5_user_processing_sqs" {
  name                        = "itsag1t5_user_processing_sqs.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  deduplication_scope   = "messageGroup"
  fifo_throughput_limit = "perMessageGroupId"
}

resource "aws_sqs_queue_policy" "itsag1t5_user_processing_sqs_policy" {
  queue_url = aws_sqs_queue.itsag1t5_user_processing_sqs.url
  policy    = data.aws_iam_policy_document.itsag1t5_user_sqs_policy_document.json
}

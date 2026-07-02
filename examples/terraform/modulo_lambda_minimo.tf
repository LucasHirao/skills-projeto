variable "project_name" {
  type        = string
  description = "Nome curto do projeto (ex.: datalake)"
}

variable "environment" {
  type        = string
  description = "Ambiente (dev, hml, prod)"
  validation {
    condition     = contains(["dev", "hml", "prod"], var.environment)
    error_message = "environment deve ser dev, hml ou prod."
  }
}

locals {
  name_prefix = "${var.project_name}-processa-arquivo-${var.environment}"
  default_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket" "input" {
  bucket = "${local.name_prefix}-input"
  tags   = local.default_tags
}

resource "aws_sqs_queue" "dlq" {
  name = "${local.name_prefix}-dlq"
  tags = local.default_tags
}

resource "aws_iam_role" "lambda" {
  name = "${local.name_prefix}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
  tags = local.default_tags
}

data "aws_iam_policy_document" "lambda_s3_read" {
  statement {
    sid       = "ReadInputBucket"
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [aws_s3_bucket.input.arn, "${aws_s3_bucket.input.arn}/*"]
  }
}

resource "aws_iam_role_policy" "lambda" {
  name   = "${local.name_prefix}-s3-read"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_s3_read.json
}

resource "aws_lambda_function" "processa" {
  function_name = local.name_prefix
  role          = aws_iam_role.lambda.arn
  handler       = "handler.handler"
  runtime       = "python3.12"
  memory_size   = 512
  timeout       = 60

  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }

  environment {
    variables = {
      INPUT_BUCKET = aws_s3_bucket.input.bucket
    }
  }

  tags = local.default_tags
}

output "lambda_arn" {
  description = "ARN da Lambda de processamento"
  value       = aws_lambda_function.processa.arn
}

output "input_bucket" {
  description = "Bucket de entrada"
  value       = aws_s3_bucket.input.bucket
}

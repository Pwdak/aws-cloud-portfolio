# ---------- Buckets S3 ----------
resource "aws_s3_bucket" "raw" {
  bucket = "uploads-bruts-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "valid" {
  bucket = "uploads-valides-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_public_access_block" "raw" {
  bucket                  = aws_s3_bucket.raw.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "valid" {
  bucket                  = aws_s3_bucket.valid.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---------- DynamoDB ----------
resource "aws_dynamodb_table" "documents" {
  name         = "documents-metadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "document_id"

  attribute {
    name = "document_id"
    type = "S"
  }

  tags = { Name = "documents-metadata" }
}

# ---------- SNS (notification équipe médicale) ----------
resource "aws_sns_topic" "medical_team" {
  name = "medical-team-notifications"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.medical_team.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# ---------- SQS (Dead Letter Queue pour les échecs) ----------
resource "aws_sqs_queue" "dlq" {
  name                      = "document-processing-dlq"
  message_retention_seconds = 1209600  # 14 jours, le max

  tags = { Name = "document-processing-dlq" }
}

# ---------- Execution role de la Lambda ----------
resource "aws_iam_role" "lambda_exec" {
  name = "role-lambda-doc-processing"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "doc_processing" {
  name = "doc-processing-permissions"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:DeleteObject"]
        Resource = "${aws_s3_bucket.raw.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.valid.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem"]
        Resource = aws_dynamodb_table.documents.arn
      },
      {
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = aws_sns_topic.medical_team.arn
      },
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = aws_sqs_queue.dlq.arn
      }
    ]
  })
}

# ---------- Log group ----------
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/process-document"
  retention_in_days = 7
}

# ---------- Package du code ----------
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

# ---------- Fonction Lambda ----------
resource "aws_lambda_function" "process_document" {
  function_name    = "process-document"
  role             = aws_iam_role.lambda_exec.arn
  runtime          = "python3.12"
  handler          = "index.handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 30
  memory_size      = 256

  environment {
    variables = {
      TABLE_NAME     = aws_dynamodb_table.documents.name
      VALID_BUCKET   = aws_s3_bucket.valid.id
      SNS_TOPIC_ARN  = aws_sns_topic.medical_team.arn
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda]
}

# ---------- Destination "on failure" vers la DLQ ----------
resource "aws_lambda_function_event_invoke_config" "process_document" {
  function_name = aws_lambda_function.process_document.function_name

  destination_config {
    on_failure {
      destination = aws_sqs_queue.dlq.arn
    }
  }

  maximum_retry_attempts = 2
}

# ---------- Resource-based policy : S3 peut invoquer la Lambda ----------
resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_document.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw.arn
}

# ---------- Trigger S3 → Lambda ----------
resource "aws_s3_bucket_notification" "raw_upload" {
  bucket = aws_s3_bucket.raw.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.process_document.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.s3_invoke]
}
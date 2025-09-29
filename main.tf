# Define the central S3 bucket in N. California (us-west-1)
resource "aws_s3_bucket" "central_lambda_code_bucket" {
  provider = aws.us-west-1
  bucket   = var.central_s3_bucket_name
  tags = {
    Name = "Lambda Code Storage"
  }
}

resource "aws_s3_bucket_versioning" "central_lambda_code_bucket_versioning" {
  provider = aws.us-west-1
  bucket   = aws_s3_bucket.central_lambda_code_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Upload the Lambda code to the central S3 bucket
resource "aws_s3_object" "lambda_code_object" {
  provider     = aws.us-west-1
  bucket       = aws_s3_bucket.central_lambda_code_bucket.id
  key          = "lambda_code.zip"
  source       = "./lambda_code.zip"
  etag         = filemd5("./lambda_code.zip")
  content_type = "application/zip"
}

# Create IAM role and policy once, as it's a global resource
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ---------------------------------------------
# Resources for Mumbai Region (ap-south-1)
# ---------------------------------------------

resource "aws_s3_bucket" "mumbai_lambda_code_bucket" {
  provider = aws.mumbai
  bucket   = "regional-lambda-code-bucket-mumbai-${random_pet.bucket_suffix.id}"
  tags = {
    Name   = "Regional Lambda Code Storage"
    Region = "ap-south-1"
  }
}

resource "aws_s3_bucket_versioning" "mumbai_lambda_code_bucket_versioning" {
  provider = aws.mumbai
  bucket   = aws_s3_bucket.mumbai_lambda_code_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "mumbai_lambda_code_object" {
  provider     = aws.mumbai
  bucket       = aws_s3_bucket.mumbai_lambda_code_bucket.id
  key          = "lambda_code.zip"
  source       = "./lambda_code.zip"
  etag         = filemd5("./lambda_code.zip")
}

resource "aws_lambda_function" "mumbai_hello_world" {
  provider      = aws.mumbai
  function_name = "HelloWorldFunction-Mumbai"
  s3_bucket     = aws_s3_bucket.mumbai_lambda_code_bucket.id
  s3_key        = aws_s3_object.mumbai_lambda_code_object.key
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_exec_role.arn
  source_code_hash = filebase64sha256("./lambda_code.zip")
}

resource "aws_cloudwatch_event_rule" "mumbai_cron_rule" {
  provider = aws.mumbai
  name     = "HelloWorldTrigger-Mumbai"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "mumbai_lambda_target" {
  provider = aws.mumbai
  rule     = aws_cloudwatch_event_rule.mumbai_cron_rule.name
  arn      = aws_lambda_function.mumbai_hello_world.arn
}

resource "aws_lambda_permission" "mumbai_allow_cloudwatch" {
  provider      = aws.mumbai
  statement_id  = "AllowExecutionFromCloudWatch-Mumbai"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mumbai_hello_world.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.mumbai_cron_rule.arn
}

# ---------------------------------------------
# Resources for Singapore Region (ap-southeast-1)
# ---------------------------------------------

resource "aws_s3_bucket" "singapore_lambda_code_bucket" {
  provider = aws.singapore
  bucket   = "regional-lambda-code-bucket-singapore-${random_pet.bucket_suffix.id}"
  tags = {
    Name   = "Regional Lambda Code Storage"
    Region = "ap-southeast-1"
  }
}

resource "aws_s3_bucket_versioning" "singapore_lambda_code_bucket_versioning" {
  provider = aws.singapore
  bucket   = aws_s3_bucket.singapore_lambda_code_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "singapore_lambda_code_object" {
  provider     = aws.singapore
  bucket       = aws_s3_bucket.singapore_lambda_code_bucket.id
  key          = "lambda_code.zip"
  source       = "./lambda_code.zip"
  etag         = filemd5("./lambda_code.zip")
}

resource "aws_lambda_function" "singapore_hello_world" {
  provider      = aws.singapore
  function_name = "HelloWorldFunction-Singapore"
  s3_bucket     = aws_s3_bucket.singapore_lambda_code_bucket.id
  s3_key        = aws_s3_object.singapore_lambda_code_object.key
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_exec_role.arn
  source_code_hash = filebase64sha256("./lambda_code.zip")
}

resource "aws_cloudwatch_event_rule" "singapore_cron_rule" {
  provider = aws.singapore
  name     = "HelloWorldTrigger-Singapore"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "singapore_lambda_target" {
  provider = aws.singapore
  rule     = aws_cloudwatch_event_rule.singapore_cron_rule.name
  arn      = aws_lambda_function.singapore_hello_world.arn
}

resource "aws_lambda_permission" "singapore_allow_cloudwatch" {
  provider      = aws.singapore
  statement_id  = "AllowExecutionFromCloudWatch-Singapore"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.singapore_hello_world.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.singapore_cron_rule.arn
}

# Generate a random suffix for the regional bucket name to ensure uniqueness
resource "random_pet" "bucket_suffix" {
  length = 2
}
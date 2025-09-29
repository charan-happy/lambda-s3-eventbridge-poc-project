# -----------------------------------------------------------------------------
# REGIONAL RESOURCES (Defined within the module)
# -----------------------------------------------------------------------------

# 1. Regional S3 Bucket & Code Upload
resource "aws_s3_bucket" "regional_lambda_code_bucket" {
  # Use bucket_prefix instead of bucket for guaranteed unique names
  # Shortened the prefix to meet the 37-character limit.
  bucket_prefix = "multi-region-lambda-${var.region_name}-"
}

resource "aws_s3_object" "regional_lambda_code_object" {
  bucket = aws_s3_bucket.regional_lambda_code_bucket.id
  key    = "lambda_code.zip"
  source = var.lambda_zip_path
  etag   = filemd5(var.lambda_zip_path)
}

# 2. Regional Lambda Function
resource "aws_lambda_function" "hello_world" {
  function_name    = "HelloWorldFunction-${var.region_name}"
  s3_bucket        = aws_s3_bucket.regional_lambda_code_bucket.id
  s3_key           = aws_s3_object.regional_lambda_code_object.key
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  role             = var.iam_role_arn
  source_code_hash = filebase64sha256(var.lambda_zip_path)
}

# 3. Regional EventBridge Rule & Target
resource "aws_cloudwatch_event_rule" "cron_rule" {
  name                = "HelloWorldTrigger-Daily-${var.region_name}"
  schedule_expression = "cron(0 10 * * ? *)" # Daily at 10:00 AM UTC
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.cron_rule.name
  arn  = aws_lambda_function.hello_world.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch-${var.region_name}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cron_rule.arn
}

# 4. Regional CloudWatch Alarm & Dashboard
resource "aws_cloudwatch_metric_alarm" "daily_execution_alarm" {
  alarm_name          = "LambdaFailureAlarm-${var.region_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 86400
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alert if the daily scheduled Lambda fails in ${var.region_name}."
  dimensions = {
    FunctionName = aws_lambda_function.hello_world.function_name
  }
}

resource "aws_cloudwatch_dashboard" "regional_dashboard" {
  dashboard_name = "MultiRegion-Daily-Lambda-${var.region_name}"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric", x = 0, y = 0, width = 12, height = 6,
        properties = {
          title   = "Daily Lambda Executions and Errors - ${upper(var.region_name)}",
          view    = "timeSeries",
          stacked = false,
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", aws_lambda_function.hello_world.function_name],
            ["AWS/Lambda", "Errors", "FunctionName", aws_lambda_function.hello_world.function_name],
          ],
          region = var.region_code
        }
      },
      {
        type = "alarm", x = 12, y = 0, width = 12, height = 6,
        properties = {
          title  = "Regional Lambda Failure Alarm",
          alarms = [aws_cloudwatch_metric_alarm.daily_execution_alarm.arn],
          region = var.region_code
        }
      }
    ]
  })
}
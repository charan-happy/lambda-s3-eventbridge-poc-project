variable "region_name" {
  description = "The friendly name of the region (e.g., 'mumbai')."
  type        = string
}

variable "region_code" {
  description = "The AWS region code (e.g., 'ap-south-1')."
  type        = string
}

variable "iam_role_arn" {
  description = "The ARN of the IAM role for the Lambda function."
  type        = string
}

variable "lambda_zip_path" {
  description = "The local path to the lambda function's zip file."
  type        = string
}

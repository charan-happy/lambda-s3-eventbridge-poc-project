variable "central_s3_bucket_name" {
  description = "The name for the central S3 bucket in us-west-1."
  type        = string
  default     = "my-project-central-lambda-code"
}

variable "s3_bucket_prefix" {
  description = "A prefix for the regional S3 buckets."
  type        = string
  default     = "regional-lambda-code-bucket"
}

variable "regions" {
  description = "Map of regions to deploy the Lambda functions."
  type        = map(string)
  default = {
    "mumbai"    = "ap-south-1"
    "singapore" = "ap-southeast-1"
  }
}
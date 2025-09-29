# -----------------------------------------------------------------------------
# GLOBAL RESOURCES (us-west-1)
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "central_lambda_code_bucket" {
  provider = aws.us-west-1
  # Use bucket_prefix for the central bucket as well for consistency
  bucket_prefix = "${var.central_s3_bucket_name}-"
}

resource "aws_s3_object" "lambda_code_object" {
  provider = aws.us-west-1
  bucket   = aws_s3_bucket.central_lambda_code_bucket.id
  key      = "lambda_code.zip"
  source   = "./lambda_code.zip"
  etag     = filemd5("./lambda_code.zip")
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "random_pet" "bucket_suffix" {
  length = 2
}

# -----------------------------------------------------------------------------
# REGIONAL DEPLOYMENTS (Calling the module for each region)
# -----------------------------------------------------------------------------

module "mumbai_deployment" {
  source    = "./modules/regional_lambda"
  providers = { aws = aws.mumbai }

  region_name     = "mumbai"
  region_code     = "ap-south-1"
  iam_role_arn    = aws_iam_role.lambda_exec_role.arn
  lambda_zip_path = "./lambda_code.zip"
  # random_suffix is removed
}

module "singapore_deployment" {
  source    = "./modules/regional_lambda"
  providers = { aws = aws.singapore }

  region_name     = "singapore"
  region_code     = "ap-southeast-1"
  iam_role_arn    = aws_iam_role.lambda_exec_role.arn
  lambda_zip_path = "./lambda_code.zip"
  # random_suffix is removed
}

module "frankfurt_deployment" {
  source    = "./modules/regional_lambda"
  providers = { aws = aws.frankfurt }

  region_name     = "frankfurt"
  region_code     = "eu-central-1"
  iam_role_arn    = aws_iam_role.lambda_exec_role.arn
  lambda_zip_path = "./lambda_code.zip"
  # random_suffix is removed
}

module "sydney_deployment" {
  source    = "./modules/regional_lambda"
  providers = { aws = aws.sydney }

  region_name     = "sydney"
  region_code     = "ap-southeast-2"
  iam_role_arn    = aws_iam_role.lambda_exec_role.arn
  lambda_zip_path = "./lambda_code.zip"
  # random_suffix is removed
}
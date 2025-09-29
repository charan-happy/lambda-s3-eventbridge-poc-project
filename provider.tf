terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.1"
    }
  }
  required_version = ">= 1.0"
}

# Default provider block with an explicit region. This is what you were missing.
provider "aws" {
  region = "us-west-1"
}

# Provider for the central S3 bucket in N. California
provider "aws" {
  alias  = "us-west-1"
  region = "us-west-1"
}

# Provider for the Mumbai region
provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}

# Provider for the Singapore region
provider "aws" {
  alias  = "singapore"
  region = "ap-southeast-1"
}
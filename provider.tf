terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
  required_version = ">= 1.0"
}

# -----------------------------------------------------------
# DEFAULT and CENTRAL PROVIDER (us-west-1)
# -----------------------------------------------------------
provider "aws" {
  region = "us-west-1" # N. California
}

provider "aws" {
  alias  = "us-west-1"
  region = "us-west-1"
}

# -----------------------------------------------------------
# EXPLICIT ALIASED PROVIDERS FOR EACH TARGET REGION
# -----------------------------------------------------------

provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "singapore"
  region = "ap-southeast-1"
}

provider "aws" {
  alias  = "frankfurt"
  region = "eu-central-1"
}

provider "aws" {
  alias  = "sydney"
  region = "ap-southeast-2"
}

# If you add a new region to locals.regions in main.tf,
# you must also add its corresponding provider block here.
# For example, for Ohio:
#
# provider "aws" {
#   alias  = "ohio"
#   region = "us-east-2"
# }
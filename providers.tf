terraform {
  required_version = ">= 1.3, < 2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
    awscc = {
      source = "hashicorp/awscc"
      version = "1.15.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }
  backend "s3" {
    encrypt        = true
  }
}

provider "aws" {
  region  = var.region
}

provider "awscc" {
  region  = var.region
}
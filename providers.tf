terraform {
  required_version = ">= 1.3, < 2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }

  backend "s3" {
    bucket         = var.s3_bucket
    key            = "codebuild/terraform.tfstate"  # Path inside the S3 bucket
    region         = var.region
    encrypt        = true  # Optional, enables server-side encryption
    #dynamodb_table = "your-dynamodb-lock-table"  # Optional, for state locking
  }
}

provider "aws" {
  region  = var.region
}

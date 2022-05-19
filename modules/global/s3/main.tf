# run with:  “terraform init -backend-config=backend.hcl”
terraform {
  backend "s3" {
    #bucket = "terraform-up-and-running-state-paul-tf"
    key = "global/s3/terraform.tfstate"
    #region = "eu-west-3"

    #dynamodb_table = "terraform-up-and-running-locks-paul-tf"
    #encrypt = true
  }
}

provider "aws" {
  region = "eu-west-3"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-up-and-running-state-paul-tf"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }

  # Enable versioning so we can see the full revision history of our state files
  versioning {
    enabled = true
  }

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks-paul-tf"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
terraform {
    backend "s3" {
        bucket = "terraform-up-and-running-state-paul-tf"
        key = "stage/data-stores/mysql/terraform.tfstate"
        region = "eu-west-3"

        dynamodb_table = "terraform-up-and-running-locks-paul-tf"
        encrypt = true
    }
}

provider "aws" {
  region = "eu-west-3"
}

resource "aws_db_instance" "example" {
  identifier_prefix   = "terraform-up-and-running"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  name                = "example_database"
  username            = "admin"

  # How should we set the password?
  password            = var.db_password

  skip_final_snapshot = true
}
terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state-paul-tf"
    key    = "prod/data-stores/mysql/terraform.tfstate"
    region = "eu-west-3"

    dynamodb_table = "terraform-up-and-running-locks-paul-tf"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-west-3"
}

module "data_store" {
  source                   = "../../../modules/data-stores/mysql"
  db_remote_state_name     = "dbprodpaul"
  db_remote_state_bucket   = "terraform-up-and-running-state-paul-tf"
  db_remote_state_key      = "prod/data-stores/mysql/terraform.tfstate"
  db_remote_state_password = var.db_password
}
terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state-paul-tf"
    key    = "stage/data-stores/mysql/terraform.tfstate"
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
  db_remote_state_name     = "dbstagepaul"
  db_remote_state_bucket   = "terraform-up-and-running-state-paul-tf"
  db_remote_state_key      = "stage/data-stores/mysql/terraform.tfstate"
  db_remote_state_password = var.db_password
}
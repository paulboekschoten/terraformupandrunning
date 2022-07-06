terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state-paul-tf"
    key    = "stage/services/webserver-cluster/terraform.tfstate"
    region = "eu-west-3"

    dynamodb_table = "terraform-up-and-running-locks-paul-tf"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-west-3"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  ami         = "ami-0c6ebbd55ab05f070"
  server_text = "New server text"

  cluster_name           = "webservers-stage-paul"
  db_remote_state_bucket = "terraform-up-and-running-state-paul-tf"
  db_remote_state_key    = "stage/data-stores/mysql/terraform.tfstate"

  instance_type        = "t2.micro"
  min_size             = 2
  max_size             = 2
  enable_autoscaling   = true
  enable_new_user_data = false

  custom_tags = {
    Owner      = "team-paul"
    DeployedBy = "terraform"
  }
}


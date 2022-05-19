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

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name = "scale-out-during-business-hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 10
  recurrence            = "0 9 * * *"

  autoscaling_group_name = module.webserver_cluster.asg_name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale-in-at-night"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *"

  autoscaling_group_name = module.webserver_cluster.asg_name
}
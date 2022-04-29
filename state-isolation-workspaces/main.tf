terraform {
    backend "s3" {
        bucket = "terraform-up-and-running-state-paul-tf"
        key = "workspaces-example/terraform.tfstate"
        region = "eu-west-3"

        dynamodb_table = "terraform-up-and-running-locks-paul-tf"
        encrypt = true
    }
}

provider "aws" {
  region = "eu-west-3"
}

resource "aws_instance" "example" {
  ami           = "ami-06ad2ef8cd7012912"
  instance_type = terraform.workspace == "default" ? "t2.medium" : "t2.micro"
}
provider "aws" {
  region = "eu-west-3"
}

resource "aws_instance" "tf-running-paul" {
  ami = "ami-0c6ebbd55ab05f070"
  instance_type = "t2.micro"
  tags = {
      Name = "terraform-example-paul"
  }
}
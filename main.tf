provider "aws" {
  region = "eu-west-3"
}

resource "aws_instance" "tf-running-paul" {
  ami = "ami-0960de83329d12f2f"
  instance_type = "t2.micro"
  tags = {
      Name = "terraform-example-paul"
  }
}
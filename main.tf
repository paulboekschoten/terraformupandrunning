provider "aws" {
  region = "eu-west-3"
}

resource "aws_instance" "tf-running-paul" {
  ami = "ami-0c6ebbd55ab05f070"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.tf-instance-paul.id]
  
  tags = {
      Name = "terraform-example-paul"
  }
  
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

}

resource "aws_security_group" "tf-instance-paul" {
  name = "terraform-example-paul"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
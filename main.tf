provider "aws" {
  region = "eu-west-3"
}

# variables
variable "http_port" {
  description = "Server port for HTTP requests."
  type = number
  default = 8080
}

#outputs
output "public_ip" {
  description = "The public ip of the web server."
  value = aws_instance.tf-running-paul.public_ip
}

#resources
resource "aws_instance" "tf-running-paul" {
  ami = "ami-0c6ebbd55ab05f070"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.tf-instance-paul.id]
  
 user_data = <<-EOF
             #!/bin/bash
             echo "Hello, World 2" > index.html
             nohup busybox httpd -f -p ${var.http_port} &
             EOF

  tags = {
      Name = "terraform-example-paul"
  }
  
}

resource "aws_security_group" "tf-instance-paul" {
  name = "terraform-example-paul"

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
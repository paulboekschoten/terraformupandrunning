provider "aws" {
  region = "eu-west-3"
}

#resources
resource "aws_launch_configuration" "tf-running-paul" {
  image_id = "ami-0c6ebbd55ab05f070"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.tf-instance-paul.id]
  
 user_data = <<-EOF
             #!/bin/bash
             echo "Hello, World 2" > index.html
             nohup busybox httpd -f -p ${var.http_port} &
             EOF

  # Required when using a launch configuration with an auto scaling group.
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "tf-running-paul" {
  launch_configuration = aws_launch_configuration.tf-running-paul.name
  vpc_zone_identifier = data.aws_subnet_ids.default.ids

  min_size = 2
  max_size = 4

  tag {
    key                 = "Name"
    value               = "terraform-asg-paul"
    propagate_at_launch = true
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

#vpc
data "aws_vpc" "default" {
    default = true  
}

#subnet
# aws_subnet_ids is deprecated, change to aws_subnets
data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}


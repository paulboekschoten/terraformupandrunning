provider "aws" {
  region = "eu-west-3"
}

# vpc
data "aws_vpc" "default" {
    default = true  
}

# subnet
# aws_subnet_ids is deprecated, change to aws_subnets
data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}

# resources
# launch config
resource "aws_launch_configuration" "tf-running-paul" {
  image_id        = "ami-0c6ebbd55ab05f070"
  instance_type   = "t2.micro"
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

# auto scaling group
resource "aws_autoscaling_group" "tf-running-paul" {
  launch_configuration = aws_launch_configuration.tf-running-paul.name
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids

  target_group_arns = [aws_lb_target_group.asg-paul.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 4

  tag {
    key                 = "Name"
    value               = "terraform-asg-paul"
    propagate_at_launch = true
  }
}

# security group instances
resource "aws_security_group" "tf-instance-paul" {
  name = "terraform-example-paul"

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# security group loadbalancer
resource "aws_security_group" "alb-paul" {
  name = "terraform-alb-paul"
  # allow all inbound http requests
  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  # allow all outbound requests, needed for health checks
  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

# loadbalancer
resource "aws_lb" "lb-paul" {
    name               = "terraform-asg-paul"
    load_balancer_type = "application"
    subnets            = data.aws_subnet_ids.default.ids
    security_groups    = [aws_security_group.alb-paul.id]
}

# listener
resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.lb-paul.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
      type = "fixed-response" 
      fixed_response {
        content_type = "text/plain"
        message_body = "404: page not found"
        status_code  = 404
      }
    }
}

# target group
resource "aws_lb_target_group" "asg-paul" {
    name     = "terraform-asg-paul"
    port     = var.http_port
    protocol = "HTTP"
    vpc_id   = data.aws_vpc.default.id

    health_check {
      path                = "/"
      protocol            = "HTTP"
      matcher             = 200
      interval            = 15
      timeout             = 3
      healthy_threshold   = 2
      unhealthy_threshold = 2
    }
}

# listener rules
resource "aws_lb_listener_rule" "asg-paul" {
    listener_arn = aws_lb_listener.http.arn
    priority     = 100

    condition {
      path_pattern {
        values = ["*"]
      }
    }

    action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.asg-paul.arn
    }
}
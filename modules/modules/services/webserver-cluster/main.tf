
# vpc
data "aws_vpc" "default" {
  default = true
}

# subnet
# aws_subnet_ids is deprecated, change to aws_subnets
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}


data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = var.db_remote_state_bucket
    key    = var.db_remote_state_key
    region = "eu-west-3"
  }
}


# resources
# launch config
resource "aws_launch_configuration" "tf-running-paul" {
  image_id        = "ami-0c6ebbd55ab05f070"
  instance_type   = var.instance_type
  security_groups = [aws_security_group.tf-instance-paul.id]

  user_data = templatefile("${path.module}/user-data.sh", {
    server_port = var.http_port
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
  })

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

  min_size = var.min_size
  max_size = var.max_size

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg"
    propagate_at_launch = true
  }
}

##auto scaling schedule
#resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
#  scheduled_action_name = "scale-out-during-business-hours"
#  min_size              = 2
#  max_size              = 10
#  desired_capacity      = 10
#  recurrence            = "0 9 * * *"
#
#  autoscaling_group_name = module.webserver_cluster.asg_name
#}
#
#resource "aws_autoscaling_schedule" "scale_in_at_night" {
#  scheduled_action_name = "scale-in-at-night"
#  min_size              = 2
#  max_size              = 10
#  desired_capacity      = 2
#  recurrence            = "0 17 * * *"
#
#  autoscaling_group_name = module.webserver_cluster.asg_name
#}

# security group instances
resource "aws_security_group" "tf-instance-paul" {
  name = "terraform-example-paul"

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }
}
# security group loadbalancer
resource "aws_security_group" "alb-paul" {
  name = "${var.cluster_name}-alb"
  # allow all inbound http requests
  ingress {
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }
  # allow all outbound requests, needed for health checks
  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }
}

# loadbalancer
resource "aws_lb" "lb-paul" {
  name               = "${var.cluster_name}-lb"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids
  security_groups    = [aws_security_group.alb-paul.id]
}

# listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.lb-paul.arn
  port              = local.http_port
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
  name     = "${var.cluster_name}-tg"
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
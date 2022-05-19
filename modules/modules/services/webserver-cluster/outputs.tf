output "lb_dns_name" {
  value       = aws_lb.lb-paul.dns_name
  description = "DNS of the load balancer."
}

output "asg_name" {
  value       = aws_autoscaling_group.tf-running-paul.name
  description = "The name of the Auto Scaling Group"
}
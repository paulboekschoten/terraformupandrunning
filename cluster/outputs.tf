output "lb_dns_name" {
  value       = aws_lb.lb-paul.dns_name
  description = "DNS of the load balancer."
}
output "dns_name" {
  value       = module.webserver_cluster.lb_dns_name
  description = "DNS of the load balancer."
}
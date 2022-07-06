output "dns_name" {
  value       = module.webserver_cluster.lb_dns_name
  description = "DNS of the load balancer."
}

output "upper_names" {
  value = [for name in var.names : upper(name)]
}

output "short_upper_names" {
  value = [for name in var.names : upper(name) if length(name) < 5]
}

# output a list with []
output "bios" {
  value = [for name, role in var.hero_thousand_faces : "${name} is the ${role}"]
}

# output a map with {}
output "upper_roles" {
  value = { for name, role in var.hero_thousand_faces : upper(name) => upper(role) }
}

output "for_directive" {
  value = <<EOF
%{for name in var.names}
  ${name}
%{endfor}
EOF
}

output "for_directive_strip_marker" {
  value = <<EOF
%{~for name in var.names}
  ${name}
%{~endfor}
EOF
}

output "if_else_directive" {
  value = "Hello, %{if var.name != ""}${var.name}%{else}(unnamed)%{endif}"
}
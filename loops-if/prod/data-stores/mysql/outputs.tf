output "address" {
  value       = module.data_store.address
  description = "Connect to the database at this endpoint"
}

output "port" {
  value       = module.data_store.port
  description = "The port the database is listening on"
}
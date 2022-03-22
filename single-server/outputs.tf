output "public_ip" {
  description = "The public ip of the web server."
  value = aws_instance.tf-running-paul.public_ip
}
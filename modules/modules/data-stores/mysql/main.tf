
resource "aws_db_instance" "example" {
  identifier_prefix = var.db_remote_state_name
  engine            = "mysql"
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = var.db_remote_state_name
  username          = "admin"

  # How should we set the password?
  password = var.db_remote_state_password

  skip_final_snapshot = true
}
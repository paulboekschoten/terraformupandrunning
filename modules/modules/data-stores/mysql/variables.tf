variable "db_remote_state_name" {
  description = "Name for database"
  type        = string
}

variable "db_remote_state_bucket" {
  description = "Bucket name for state files"
  type        = string
}

variable "db_remote_state_key" {
  description = "Location of the state files in the bucket"
  type        = string
}

variable "db_remote_state_password" {
  description = "Password for the database"
  type        = string
}
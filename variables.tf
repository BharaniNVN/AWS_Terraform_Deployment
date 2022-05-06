# root/varaibles.tf #

variable "aws_region" {
  default = "us-west-2"
}

## DB Variabled ##

variable "db_name" {
  type = string
}

variable "dbuser" {
  type      = string
  sensitive = true
}

variable "dbpassword" {
  type      = string
  sensitive = true
}
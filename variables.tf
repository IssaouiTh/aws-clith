variable "aws_region" {
  default = "eu-west-3"
}

variable "azs" {
  type    = list(string)
  default = ["eu-west-3a", "eu-west-3b"]
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

# 8 SUBNETS (2 AZ × 4 tiers)

variable "public_cidrs" {
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "web_cidrs" {
  default = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "app_cidrs" {
  default = ["10.0.4.0/24", "10.0.5.0/24"]
}

variable "data_cidrs" {
  default = ["10.0.6.0/24", "10.0.7.0/24"]
}

variable "db_name" {
  default = "signupdb"
}

variable "db_username" {
  default = "appuser"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "my_ip" {
  description = "IP perso pour SSH"
  type        = string
}

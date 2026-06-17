variable "region" {
  default = "eu-west-3"
}

variable "az" {
  description = "Zone de dispo pour les 2 instances (meme AZ)"
  default     = "eu-west-3a"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "my_ip" {
  description = "Ton IP publique en /32"
  type        = string
}

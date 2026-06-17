# VPC par defaut du compte (172.31.0.0/16)
data "aws_vpc" "default" {
  default = true
}

# Un sous-reseau par defaut dans l'AZ choisie
data "aws_subnet" "selected" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = var.az
  default_for_az    = true
}

# Derniere AMI Amazon Linux 2023
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_route_table" "main" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "association.main"
    values = ["true"]
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

data "http" "myip" {
  url = "https://checkip.amazonaws.com"
}

locals {
  my_ip       = "${chomp(data.http.myip.response_body)}/32"
  third_octet = 200 + parseint(substr(md5(var.prefix), 0, 2), 16) % 50
  subnet_cidr = "172.31.${local.third_octet}.0/24"
}

data "aws_vpc" "default" {
  default = true
}

locals {
  public_cidrs = ["172.31.160.0/24", "172.31.161.0/24"]
  web_cidrs    = ["172.31.162.0/24", "172.31.163.0/24"]
  app_cidrs    = ["172.31.164.0/24", "172.31.165.0/24"]
}

resource "aws_subnet" "public_lucas" {
  count                   = length(var.azs)
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = local.public_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "td-public-lucas-${count.index}" }
}

resource "aws_subnet" "web_lucas" {
  count                   = length(var.azs)
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = local.web_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "td-web-lucas-${count.index}" }
}

resource "aws_subnet" "app_lucas" {
  count                   = length(var.azs)
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = local.app_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "td-app-lucas-${count.index}" }
}

locals {
  public_subnet_ids = aws_subnet.public_lucas[*].id
  web_subnet_ids    = aws_subnet.web_lucas[*].id
  app_subnet_ids    = aws_subnet.app_lucas[*].id
}

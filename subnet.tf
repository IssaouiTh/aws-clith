resource "aws_subnet" "td" {
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = local.subnet_cidr
  availability_zone       = var.az
  map_public_ip_on_launch = false
  tags                    = { Name = "${var.prefix}-subnet" }
}

resource "aws_route_table_association" "td" {
  subnet_id      = aws_subnet.td.id
  route_table_id = data.aws_route_table.main.id
}

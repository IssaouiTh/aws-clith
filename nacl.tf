resource "aws_network_acl" "td" {
  vpc_id     = data.aws_vpc.default.id
  subnet_ids = [aws_subnet.td.id]
  tags       = { Name = "${var.prefix}-nacl" }
}

resource "aws_network_acl_rule" "in_ssh" {
  network_acl_id = aws_network_acl.td.id
  rule_number    = 100
  egress         = false
  protocol       = "6"
  rule_action    = "allow"
  cidr_block     = local.my_ip
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "out_ephemeral" {
  count          = var.nacl_block_return ? 0 : 1
  network_acl_id = aws_network_acl.td.id
  rule_number    = 100
  egress         = true
  protocol       = "6"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "in_deny_ssh" {
  count          = var.nacl_deny_ssh ? 1 : 0
  network_acl_id = aws_network_acl.td.id
  rule_number    = 90
  egress         = false
  protocol       = "6"
  rule_action    = "deny"
  cidr_block     = local.my_ip
  from_port      = 22
  to_port        = 22
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.td.id
  key_name                    = aws_key_pair.td.key_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  tags                        = { Name = "${var.prefix}-bastion" }
}

resource "aws_instance" "cible" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.td.id
  key_name                    = aws_key_pair.td.key_name
  vpc_security_group_ids      = [aws_security_group.cible.id]
  associate_public_ip_address = false
  tags                        = { Name = "${var.prefix}-cible" }
}

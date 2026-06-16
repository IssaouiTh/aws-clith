resource "aws_security_group" "sg_bastion" {
  name        = "thoubei-sg-bastion"
  description = "SSH depuis mon IP vers bastion"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["82.96.161.255/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "thoubei-sg-bastion"
  }
}

resource "aws_security_group" "sg_cible" {
  name        = "thoubei-sg-cible"
  description = "Acces cible depuis bastion"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_bastion.id]
  }

  ingress {
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = [aws_security_group.sg_bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "thoubei-sg-cible"
  }
}

resource "aws_subnet" "thoubei_subnet" {
  vpc_id     = var.vpc_id
  cidr_block = "172.31.140.0/24"

  tags = {
    Name = "thoubei_subnet"
  }
}

resource "aws_key_pair" "thoubei_key" {
  key_name   = "thoubei_key"
  public_key = file(pathexpand("~/.ssh/thoubei_key.pub"))
}

resource "aws_instance" "td_bastion" {
  ami                         = var.vm_image
  instance_type               = var.vm_instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.thoubei_subnet.id
  vpc_security_group_ids      = [aws_security_group.sg_bastion.id]
  key_name                    = aws_key_pair.thoubei_key.key_name

  tags = {
    Name = "td-bastion-thoubei"
  }
}

resource "aws_instance" "td_cible" {
  ami                         = var.vm_image
  instance_type               = var.vm_instance_type
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.thoubei_subnet.id
  vpc_security_group_ids      = [aws_security_group.sg_cible.id]
  key_name                    = aws_key_pair.thoubei_key.key_name

  tags = {
    Name = "td-cible-thoubei"
  }
}

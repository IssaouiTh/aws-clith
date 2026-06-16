resource "aws_security_group" "thoubei" {
  name        = "thoubei"
  description = "Security group thoubei"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "thoubei"
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

resource "aws_instance" "thoubei_serverweb" {
  ami                         = var.vm_image
  instance_type               = var.vm_instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.thoubei_subnet.id
  vpc_security_group_ids      = [aws_security_group.thoubei.id]
  key_name                    = aws_key_pair.thoubei_key.key_name

  tags = {
    Name = "thoubei_serverweb"
  }
}

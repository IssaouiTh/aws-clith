resource "aws_key_pair" "td" {
  key_name   = "${var.prefix}-cle"
  public_key = file("${path.module}/cle-quentin.pub")
}

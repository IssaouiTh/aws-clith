resource "aws_key_pair" "td" {
  key_name   = "cle-td"
  public_key = file("${path.module}/cle-td.pub")
}

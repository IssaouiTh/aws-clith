output "bastion_public_ip" {
  value = aws_instance.td_bastion.public_ip
}

output "cible_private_ip" {
  value = aws_instance.td_cible.private_ip
}

output "bastion_id" {
  value = aws_instance.td_bastion.id
}

output "cible_id" {
  value = aws_instance.td_cible.id
}

output "subnet_id" {
  value = aws_subnet.thoubei_subnet.id
}

output "sg_bastion_id" {
  value = aws_security_group.sg_bastion.id
}

output "sg_cible_id" {
  value = aws_security_group.sg_cible.id
}
output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "cible_private_ip" {
  value = aws_instance.cible.private_ip
}

output "ssh_bastion" {
  value = "ssh -i cle-td ec2-user@${aws_instance.bastion.public_ip}"
}

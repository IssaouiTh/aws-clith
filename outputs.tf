output "mon_ip_detectee"   { value = local.my_ip }
output "subnet_dedie"      { value = local.subnet_cidr }
output "bastion_public_ip" { value = aws_instance.bastion.public_ip }
output "cible_private_ip"  { value = aws_instance.cible.private_ip }
output "ssh_bastion" {
  value = "ssh -i cle-quentin -o IdentitiesOnly=yes ec2-user@${aws_instance.bastion.public_ip}"
}

# aws-clith — TD Jour 1 : Sécurité réseau AWS (Terraform)

Auteur : Quentin Kail — Région eu-west-3 — Compte partagé 747082607185

Déploiement d'un réseau AWS sécurisé dans le VPC par défaut : un **bastion**
(IP publique, entrée SSH) et une **cible** (sans IP publique), un **sous-réseau
dédié** avec **NACL** (stateless) et des **Security Groups** (stateful).
Toutes les ressources sont préfixées `quentin-kail-` (compte partagé).

## Fichiers
- `provider.tf` providers aws + http, région eu-west-3
- `variables.tf` region, prefix, az, toggles NACL
- `data.tf` VPC/route table par défaut, AMI AL2023, détection IP auto, /24 calculé
- `subnet.tf` sous-réseau dédié + association au routage par défaut
- `keypair.tf` paire de clés EC2 (lit `cle-quentin.pub`, non versionnée)
- `security_groups.tf` SG bastion (SSH depuis mon IP) + SG cible (depuis SG bastion)
- `instances.tf` bastion (IP publique) + cible (sans IP publique)
- `nacl.tf` NACL sur le sous-réseau dédié (entrée SSH + sortie ports éphémères)
- `outputs.tf` IP bastion, IP privée cible, commande SSH

## Déploiement
```bash
ssh-keygen -t ed25519 -f cle-quentin -N "" -C "cle-quentin"   # clé locale, non versionnée
terraform init && terraform apply
```
SSH : `ssh -i cle-quentin -o IdentitiesOnly=yes ec2-user@$(terraform output -raw bastion_public_ip)`

## Manips du PDF (réversibles)
- Piège stateless (Partie 5) : `terraform apply -var nacl_block_return=true`
- Défense en profondeur (Partie 6) : `terraform apply -var nacl_deny_ssh=true`
- Retour normal : `terraform apply`

## Nettoyage
```bash
terraform destroy
```
Le VPC par défaut, ses sous-réseaux et son IGW ne sont jamais touchés.

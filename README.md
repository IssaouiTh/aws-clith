# aws-clith
# aws-clith
# AWS CLI - Terraform - Ansible

## Auteur

**Thoubaita Vadio Lucas**
Mastère Cybersécurité – IPSSI
AWS Academy – Boris Rose

---

# Objectif du projet

L'objectif de ce projet est de mettre en place une infrastructure AWS sécurisée à l'aide de Terraform et d'Ansible.

Le projet permet de :

* Créer automatiquement l'infrastructure AWS.
* Déployer un bastion accessible depuis Internet.
* Déployer une machine cible isolée sans adresse IP publique.
* Configurer les Security Groups.
* Mettre en œuvre une architecture de défense en profondeur.
* Préparer l'automatisation de la configuration via Ansible.

---

# Technologies utilisées

* AWS EC2
* AWS VPC
* AWS Security Groups
* AWS Network ACL
* Terraform
* Ansible
* Git / GitHub
* WSL Debian 13

---

# Architecture

## Bastion

Le bastion est une instance EC2 Ubuntu disposant :

* d'une adresse IP publique ;
* d'un accès SSH contrôlé ;
* d'un Security Group dédié.

Le bastion sert de point d'entrée sécurisé vers l'infrastructure.

## Cible

La machine cible :

* est située dans le même sous-réseau ;
* ne possède aucune adresse IP publique ;
* n'est accessible qu'à travers le bastion.

---

# Terraform

Terraform est utilisé pour créer automatiquement :

* le subnet ;
* les Security Groups ;
* la paire de clés SSH ;
* l'instance EC2 Bastion ;
* l'instance EC2 Cible.

## Ressources créées

### Security Groups

#### SG Bastion

Autorise :

* SSH (22) depuis l'adresse IP de l'administrateur.

#### SG Cible

Autorise :

* SSH (22) depuis le Security Group du bastion ;
* ICMP (ping) depuis le Security Group du bastion.

### EC2

#### td-bastion-thoubei

* Ubuntu
* IP publique activée

#### td-cible-thoubei

* Ubuntu
* IP publique désactivée

---

# Tests réalisés

## Accès SSH Bastion

Connexion depuis le poste local :

```bash
ssh -i ~/.ssh/thoubei_key ubuntu@IP_BASTION
```

Résultat :

* connexion réussie.

## Ping Bastion → Cible

```bash
ping IP_PRIVEE_CIBLE
```

Résultat :

* communication interne autorisée.

## SSH Bastion → Cible

```bash
ssh ubuntu@IP_PRIVEE_CIBLE
```

Résultat :

* accès autorisé uniquement depuis le bastion.

---

# Network ACL

Une NACL personnalisée a été créée afin d'illustrer le fonctionnement stateless des ACL AWS.

## Règles

### Entrée

* TCP 22 Allow

### Sortie

* TCP 1024-65535 Allow

### Test de blocage

Ajout d'une règle :

* Rule 90 Deny TCP 22

Résultat :

* le Security Group autorise toujours le trafic ;
* la NACL bloque la connexion ;
* démonstration de la défense en profondeur.

---

# GitHub

Travail réalisé sur la branche :

```text
bastion-soubeith
```

Le projet est versionné avec Git et hébergé sur GitHub.

---

# Conclusion

Ce projet a permis de comprendre :

* le fonctionnement des VPC AWS ;
* la différence entre Security Groups et NACL ;
* la notion de bastion ;
* l'isolation d'une machine sans adresse IP publique ;
* l'automatisation d'une infrastructure avec Terraform ;
* la préparation au déploiement automatisé avec Ansible.

Cette architecture applique plusieurs bonnes pratiques de sécurité cloud et met en œuvre une défense en profondeur grâce à l'utilisation combinée des Security Groups et des Network ACL.

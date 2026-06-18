Auteur :
Lucas
Thoubaita
Vadio


Projet de déploiement d'infrastructure AWS, réalisé de deux façons complémentaires :

- **CLI** (`infra/cli/`) : scripts Bash qui créent des Network ACLs.
- **Terraform** (`infra/terraform/`) : un security group, un subnet, une paire de clés SSH et une instance EC2.
- **Ansible** (`infra/ansible/`) : configuration post-déploiement de l'instance (nginx).

> ⚠️ **Compte AWS partagé.** Tout le monde travaille sur le même compte (`747082607185`), en région **eu-west-3**. Chaque ressource créée doit donc être **personnalisée** (noms, tags, plage réseau, clé SSH) pour ne pas entrer en conflit avec celles des autres.

---

## Structure du projet

```
.
├── README.md
├── infra
│   ├── ansible
│   │   ├── inventory.ini
│   │   └── nginx.yml
│   ├── cli
│   │   ├── constants
│   │   │   └── constants.sh
│   │   └── services
│   │       └── ec2.sh
│   ├── main.sh
│   └── terraform
│       ├── main.tf
│       ├── outputs.tf
│       ├── terraform.tf
│       └── variables.tf
└── infra/terraform/terraform.tfvars   # créé localement, non versionné
```

---

## 1. Prérequis (WSL Debian)

```bash
# AWS CLI v2 (installation dans /tmp, PAS dans le projet)
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
cd -

# jq + Terraform
sudo apt update && sudo apt install -y jq gnupg curl lsb-release
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform
```

Vérification :

```bash
aws --version
jq --version
terraform -version
```

---

## 2. Récupérer le projet

Via Git :

```bash
git clone https://github.com/IssaouiTh/aws-clith.git
cd aws-clith
```

Ou via une archive zip reçue :

```bash
cd ~
unzip /mnt/c/Users/TON_USER/Downloads/aws-cli-v1.zip
cd aws-cli-v1-main
```

---

## 3. Configurer l'accès AWS

```bash
aws configure                       # entre TES clés IAM du compte partagé
aws configure set region eu-west-3  # même région que le projet
aws sts get-caller-identity         # doit afficher "Account": "747082607185"
```

> Les clés IAM sont fournies par l'admin/le prof. Ne les colle **jamais** ailleurs que dans `aws configure`.

---

## 4. Fichiers à créer

Ces fichiers ne sont pas versionnés, c'est volontaire — chacun crée les siens.

**a) `terraform.tfvars`**

```bash
cat > infra/terraform/terraform.tfvars << 'TFV'
aws_region       = "eu-west-3"
vpc_id           = "vpc-0ebcdb39f7a526ef9"
vm_image         = "ami-0264a86fe7fd257ba"
vm_instance_type = "t2.micro"
TFV
```

**b) Ta paire de clés SSH** (remplace `PRENOM` par ton nom)

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/PRENOM_key -N ""
```

---

## 5. Personnaliser `infra/terraform/main.tf`

Le compte étant partagé, les noms et la plage réseau doivent être **uniques** :

- Remplace partout le nom générique (ex. `yokozuna`) par **ton prénom** (`marie_sg`, `marie_subnet`, `marie_key`, `marie_serverweb`...) — y compris dans les tags `Name`.
  - Le `name` du security group et le `key_name` doivent être uniques sur le compte, sinon `apply` échoue.
- Mets le chemin de ta clé : `public_key = file(pathexpand("~/.ssh/PRENOM_key.pub"))`.
- Choisis une plage de subnet **libre** en `/24`. Vérifie les plages déjà prises :

```bash
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-0ebcdb39f7a526ef9" \
  --query "Subnets[].CidrBlock" --output table
```

Prends-en une qui n'apparaît pas dans la liste (ex. `172.31.120.0/24`).

---

## 6. Déployer avec Terraform

```bash
cd infra/terraform
terraform init        # télécharge le provider AWS
terraform validate    # doit afficher "Success!"
terraform plan        # doit afficher "Plan: 4 to add"
terraform apply        # tape "yes" pour créer réellement
```

L'IP publique de la VM s'affiche dans les `Outputs` après l'`apply`.

---

## 7. Partie CLI — Network ACLs

```bash
cd infra
./main.sh ma-nacl-test
```

---

## 8. Partie Ansible

Le dossier `infra/ansible/` contient un inventaire (`inventory.ini`) et un playbook (`nginx.yml`) destinés à configurer l'instance après son déploiement (installation/configuration de nginx). Adapte `inventory.ini` avec l'IP publique obtenue à l'étape 6, puis lance le playbook selon les besoins du TP.

---

## 9. Nettoyage (important, en fin de TP)

L'instance EC2 est **facturée** hors free tier :

```bash
cd infra/terraform
terraform destroy     # supprime VM + SG + subnet + clé
```

---

## Bonnes pratiques

- Ne **jamais** committer : `terraform.tfvars`, `*.tfstate`, `*.tfstate.backup`, le dossier `.terraform/`, ou une clé privée SSH. Ajoute-les à un `.gitignore`.
- Vérifie toujours `aws sts get-caller-identity` avant de lancer `apply` pour confirmer le bon compte/région.
- Restreins les accès SSH (security group) à des IP précises plutôt qu'à `0.0.0.0/0`.

---

## Récapitulatif

| Action | Quoi |
|---|---|
| **Créer** | `terraform.tfvars`, ta clé SSH |
| **Modifier** | nom générique → ton prénom, plage subnet libre, chemin de ta clé |
| **Vérifier** | accès AWS au compte `747082607185`, région `eu-west-3` |
| **Ne pas oublier** | `terraform destroy` à la fin |

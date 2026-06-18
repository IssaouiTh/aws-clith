data "aws_db_instance" "postgres" {
  db_instance_identifier = "td-ipssi-rds-v2"
}

data "aws_secretsmanager_secret_version" "rds_creds" {
  secret_id = "td-ipssi-rds-v2/password"
}

locals {
  rds_creds   = jsondecode(data.aws_secretsmanager_secret_version.rds_creds.secret_string)
  rds_db_name = "mydb"
}

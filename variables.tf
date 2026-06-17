variable "region"        { default = "eu-west-3" }
variable "instance_type" { default = "t3.micro" }
variable "az"            { default = "eu-west-3a" }

variable "prefix" {
  description = "Prefixe de nommage"
  default     = "quentin-kail"
}

variable "nacl_block_return" {
  description = "true = retire la sortie ephemere (piege stateless, Partie 5)"
  default     = false
}

variable "nacl_deny_ssh" {
  description = "true = ajoute un deny n.90 (defense en profondeur, Partie 6)"
  default     = false
}

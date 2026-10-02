variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.2.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.2.1.0/24"
}

variable "availability_zone" {
  type    = string
  default = "eu-west-1a"
}

variable "instance_type" {
  type    = string
  default = "t2.nano"
}

variable "key_pair_name" {
  description = "Nom de la key pair EC2 existante"
  type        = string
  default     = null
}

variable "my_ip" {
  description = "Ton IP publique en /32 pour un acces SSH de secours si besoin"
  type        = string
}
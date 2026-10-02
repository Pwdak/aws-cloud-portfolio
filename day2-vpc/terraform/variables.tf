variable "aws_region" {
  description = "Région AWS cible"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  description = "CIDR block du VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
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
  description = "Nom de la key pair EC2 existante (créée à la main dans la console pour ce lab)"
  type        = string
}

variable "my_ip" {
  description = "Ton IP publique en /32 pour restreindre le SSH sur le bastion"
  type        = string
}
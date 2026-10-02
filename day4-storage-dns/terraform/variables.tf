variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.1.1.0/24"
}

variable "public_subnet_2_cidr" {
  type    = string
  default = "10.1.3.0/24"
}

variable "availability_zone" {
  type    = string
  default = "eu-west-1a"
}

variable "availability_zone_2" {
  type    = string
  default = "eu-west-1b"
}

variable "instance_type" {
  type    = string
  default = "t2.nano"
}

variable "key_pair_name" {
  description = "Nom de la key pair EC2 existante"
  type        = string
}

variable "my_ip" {
  description = "Ton IP publique en /32"
  type        = string
}

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

variable "public2_subnet_cidr" {
  type    = string
  default = "10.2.2.0/24"
}

variable "availability_zone2" {
  type    = string
  default = "eu-west-1b"
}

variable "key_pair_name" {
  description = "Nom de la key pair EC2 existante"
  type        = string
  default     = null
}

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

variable "public_subnet_2_cidr" {
  description = "CIDR du 2e subnet public (autre AZ, requis pour l'ALB)"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR du 2e subnet privé (autre AZ)"
  type        = string
  default     = "10.0.4.0/24"
}

variable "availability_zone_2" {
  type    = string
  default = "eu-west-1b"
}

variable "asg_min_size" {
  type    = number
  default = 2
}

variable "asg_desired_capacity" {
  type    = number
  default = 2
}

variable "asg_max_size" {
  type    = number
  default = 4
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
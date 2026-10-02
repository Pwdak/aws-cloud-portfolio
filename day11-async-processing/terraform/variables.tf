variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "notification_email" {
  description = "Email de l'équipe médicale pour les notifications SNS"
  type        = string
}
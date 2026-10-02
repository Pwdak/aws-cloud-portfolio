output "instance_id" {
  value = aws_instance.web.id
}

output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "kms_key_arn" {
  value = aws_kms_key.lab.arn
}

output "secret_arn" {
  value = aws_secretsmanager_secret.db_credentials.arn
}
# ---------- CMK KMS ----------
resource "aws_kms_key" "lab" {
  description             = "CMK pour chiffrement labo Jour 7"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = { Name = "kms-lab-day7" }
}

resource "aws_kms_alias" "lab" {
  name          = "alias/lab-day7-key"
  target_key_id = aws_kms_key.lab.key_id
}

# ---------- Secret Manager ----------
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "lab-day7-db-credentials"
  description = "Secret de test pour le labo Jour 7"
  kms_key_id  = aws_kms_key.lab.arn

  recovery_window_in_days = 7

  tags = { Name = "secret-db-day7" }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = "admin"
    password = "ChangeMe1234!"
  })
}
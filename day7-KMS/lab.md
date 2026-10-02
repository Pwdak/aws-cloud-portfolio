KMS : va dans KMS → Customer managed keys → Create key (type Symmetric). Observe la Key policy générée par défaut (JSON) — repère où sont définis les administrateurs et les utilisateurs de la clé.
S3 chiffré avec ta CMK : sur un bucket S3 existant (ou nouveau), va dans Properties → Default encryption → sélectionne ta CMK au lieu de la clé S3 managée par défaut. Upload un fichier, observe dans les propriétés de l'objet que le chiffrement utilise bien ta clé.
Secrets Manager : crée un secret manuellement (type "Other type of secret"), avec un JSON {"username": "admin", "password": "test1234"}. Observe le coût affiché, la clé KMS utilisée par défaut pour le chiffrer.

# COMMANDS

terraform.exe plan
terraform.exe apply
aws secretsmanager get-secret-value --secret-id lab-day7-db-credentials --query SecretString --output text
🔧 Labo Jour 1 — version Console AWS
Va dans IAM → Roles → Create role
Type de trusted entity : AWS service → sélectionne EC2
Dans les permissions, cherche et coche AmazonS3ReadOnlyAccess (on utilisera une policy managée pour l'instant, on créera du custom JSON plus tard)
Nomme le role EC2-S3-ReadOnly, crée-le
Va dans EC2 → Launch Instance, configure une instance basique (t2.micro, Amazon Linux 2023)
Dans la section "Advanced details" → "IAM instance profile", sélectionne le role que tu viens de créer
Lance l'instance, connecte-toi en SSH (comme d'habitude avec ta clé .pem)
Une fois connecté, tape simplement :
   aws s3 ls

Ça devrait fonctionner sans avoir rien configuré côté credentials — c'est le point clé à comprendre : les credentials viennent automatiquement du role attaché à l'instance.

Fais ce labo et dis-moi si aws s3 ls te renvoie bien une liste (même vide) de buckets, ou si tu as une erreur.

# SOLUTION 
Excellent, ça confirme que tu as bien compris le concept clé : aucune clé API n'a été configurée manuellement, et pourtant aws s3 ls fonctionne. C'est exactement le mécanisme que les recruteurs adorent tester.

Pourquoi ça marche (le détail qui fait la différence en entretien)

Quand tu tapes aws s3 ls depuis l'instance, la CLI va chercher des credentials dans un ordre précis :

Variables d'environnement (AWS_ACCESS_KEY_ID...)
Fichier ~/.aws/credentials
Instance Metadata Service (IMDS) — http://169.254.169.254/latest/meta-data/iam/security-credentials/

Comme tu n'as rien configuré aux étapes 1 et 2, la CLI est tombée sur l'étape 3 : elle interroge le metadata service local de l'instance, qui lui renvoie des credentials temporaires générés par STS via le role attaché.

Tu peux vérifier ça toi-même sur l'instance avec :

curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/EC2-S3-ReadOnly

Tu verras un JSON avec AccessKeyId, SecretAccessKey, Token, et une Expiration. C'est un point d'entretien classique : "Comment une EC2 récupère-t-elle ses credentials sans clé en dur ?"

⚠️ Point de sécurité important lié à ça : c'est exactement ce mécanisme qui a été exploité lors de la faille Capital One (2019) — une SSRF a permis d'interroger le metadata service et de voler les credentials du role IAM attaché à l'instance. D'où l'existence d'IMDSv2 (token-based, obligatoire aujourd'hui par défaut) qu'on verra en Priorité 5 (sécurité).
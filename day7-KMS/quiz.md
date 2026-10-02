Quiz Jour 7

Q1 — Explique le principe d'envelope encryption utilisé par KMS. Pourquoi AWS ne chiffre-t-il pas directement un fichier de 5 Go en l'envoyant à KMS ?

Q2 — Un développeur a une IAM policy qui autorise kms:Decrypt sur une CMK spécifique, mais il reçoit quand même une erreur AccessDenied quand il essaie de déchiffrer une donnée. Quelle est la cause la plus probable ?

Q3 — Pourquoi ne peux-tu pas supprimer une clé KMS immédiatement, même si tu es certain de ne plus en avoir besoin ? Quel est le risque qu'AWS cherche à éviter avec le délai imposé ?

Q4 (en anglais) — "A teammate says: 'Let's just use Parameter Store for our RDS password instead of Secrets Manager, it's free.' Explain in 2-3 sentences why this might not be the best choice for production."

Q5 (coûts/architecture) — Tu as 50 secrets différents (API keys tierces, credentials DB) à gérer pour une application en production. Certains nécessitent une rotation stricte (DB), d'autres non (API keys statiques de partenaires). Comment répartis-tu ces 50 secrets entre Parameter Store et Secrets Manager, et pourquoi ?
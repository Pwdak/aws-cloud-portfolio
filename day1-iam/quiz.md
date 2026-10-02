Mini quiz Jour 1 (réponds vite, à l'oral d'un recruteur)
Pourquoi est-ce une mauvaise pratique de créer un IAM User avec une Access Key en dur pour une application qui tourne sur EC2 ?
Quelle est la différence entre une Trust Policy et une Permission Policy ?
Si une Identity-based policy autorise une action mais qu'une Resource-based policy (ex: bucket policy S3) la refuse, que se passe-t-il ?

Reponses :
Réponse 1 — Pourquoi éviter une Access Key en dur pour une app sur EC2 ?

Plusieurs raisons, dans l'ordre de gravité pour un recruteur :

Risque de fuite : une clé en dur dans du code, un fichier de config, ou pire un repo Git, peut être exfiltrée (scan automatique de repos publics, logs, etc.). C'est la cause n°1 de compromission de comptes AWS.
Pas de rotation automatique : une clé statique reste valide tant que tu ne la révoques pas manuellement. Un role, lui, génère des credentials temporaires via STS (expiration en quelques heures max).
Pas de traçabilité fine : avec un role, chaque action dans CloudTrail est liée à la session assumée (avec un identifiant de session), ce qui facilite l'audit. Une clé statique partagée entre plusieurs process est plus difficile à tracer.
Blast radius plus large : si la clé fuit, elle reste exploitable partout, depuis n'importe où (ta machine perso, un VPS externe...), alors qu'un role attaché à une instance ne peut être assumé que dans le contexte prévu (trust policy).

C'est l'équivalent conceptuel de committer un mot de passe root en clair dans un docker-compose.yml versionné, plutôt que d'utiliser un secret Vault avec TTL — même logique de risque.

Réponse 2 — Trust Policy vs Permission Policy
Trust Policy (attachée uniquement aux roles, jamais aux users) : répond à la question "qui a le droit d'assumer ce role ?". Elle définit le Principal autorisé (un service AWS comme ec2.amazonaws.com, un autre compte AWS, un utilisateur fédéré via SAML/OIDC...).
Permission Policy (attachée aux users, groups, ou roles) : répond à la question "une fois que je suis cette identité, qu'ai-je le droit de faire ?". Elle définit les actions autorisées/refusées sur des ressources.

Piège d'entretien classique : un candidat dit "j'ai donné les droits S3 au role" en pensant à la trust policy, alors qu'il fallait modifier la permission policy. Les deux sont des documents JSON séparés, avec des rôles totalement différents.

Réponse 3 — Identity-based Allow + Resource-based Deny → refus

Un Deny explicite gagne toujours, peu importe où il se trouve dans l'évaluation. C'est la règle d'or IAM : explicit deny > explicit allow > implicit deny (par défaut).

Identity-based vs Resource-based policies — le détail

C'est un point que beaucoup de candidats maîtrisent mal, donc creusons.

Identity-based policy
Attachée à une identité : User, Group, ou Role.
Répond à : "qu'est-ce que CETTE identité peut faire ?"
Exemple : le role EC2-S3-ReadOnly que tu as créé a une identity-based policy (AmazonS3ReadOnlyAccess) qui dit "cette identité peut faire s3:GetObject, s3:ListBucket sur *".
Équivalent conceptuel Keycloak : un rôle attribué à un client/utilisateur.
Resource-based policy
Attachée directement à une ressource (pas à une identité) : bucket S3 (bucket policy), KMS key policy, SQS queue policy, Secrets Manager, etc. Attention : tous les services AWS n'en supportent pas (EC2 par exemple n'a pas de resource-based policy).
Répond à : "qui a le droit d'accéder à CETTE ressource, même si cette identité vient d'un autre compte AWS ?"
Cas d'usage typique : accès cross-account. Tu veux qu'un compte AWS externe accède à ton bucket S3 sans créer de role IAM dans ton compte pour eux → tu écris une bucket policy avec leur Principal (leur ARN de compte/role).
Comment AWS évalue les deux ensemble

Pour une requête sur S3 par exemple, AWS évalue l'union logique des deux (sauf cross-account, voir plus bas) :

Identity-based policy: Allow s3:GetObject
Resource-based policy (bucket policy): (rien, ou Allow aussi)
→ Résultat: Allow

Mais dès qu'un Deny explicite apparaît dans l'une des deux, il prime :

Identity-based policy: Allow s3:GetObject sur bucket X
Bucket policy: Deny s3:GetObject si IP hors de 10.0.0.0/8 (ex: condition IP)
→ Résultat: Deny (si la condition Deny matche)
La nuance cross-account (souvent posée en entretien senior)
Même compte : Identity-based policy suffit — pas besoin de resource-based policy si l'identité et la ressource sont dans le même compte AWS.
Cross-account (User/Role du compte A veut accéder à une ressource du compte B) : il faut les deux — une identity-based policy dans le compte A qui autorise l'action, ET une resource-based policy dans le compte B qui autorise ce principal externe. Un seul des deux ne suffit pas.

C'est une question typique posée à un niveau senior : "Un développeur dans le compte A n'arrive pas à accéder à un bucket S3 du compte B alors que sa policy IAM autorise s3:GetObject. Pourquoi ?" → Réponse attendue : il manque la bucket policy côté compte B autorisant le principal du compte A.
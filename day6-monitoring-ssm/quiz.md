Bien — tu as maintenant la boucle complète : provisionner (Terraform) → observer/monitorer (CloudWatch) → auditer qui a fait quoi (CloudTrail) → administrer sans exposition réseau (Session Manager). C'est exactement le cycle opérationnel qu'on attend d'un Cloud Engineer en entreprise, pas juste "savoir créer des ressources".

### Résumé Jour 6

- **CloudWatch** : Metrics (standard vs high resolution), Alarms (`evaluation_periods`/`datapoints_to_alarm` pour éviter le flapping), Logs (Log Groups avec retention policy à définir explicitement), CloudWatch Agent pour les métriques internes OS
- **CloudTrail** : audit de tous les appels API, Management events (activés par défaut) vs Data events (désactivés par défaut, volume/coût), essentiel pour l'investigation d'incident ("qui a fait quoi")
- **Systems Manager** : Session Manager (accès shell sans SSH/bastion/port ouvert), Run Command (exécution à la volée sur une flotte), Parameter Store (config/secrets basiques) vs Secrets Manager (rotation automatique), tout ça nécessite le rôle IAM `AmazonSSMManagedInstanceCore`

---

### Quiz Jour 6

**Q1** — Pourquoi Session Manager n'a-t-il besoin d'aucun port entrant ouvert dans le Security Group, contrairement à SSH classique ?

**Q2** — Quelle est la différence entre un Management event et un Data event dans CloudTrail ? Donne un exemple de chaque.

**Q3** — Un Log Group CloudWatch a été créé il y a 2 ans sans retention policy définie. Quel est le risque concret, et comment le corriges-tu ?

**Q4 (en anglais)** — *"A junior engineer asks you: 'Why use Parameter Store instead of just hardcoding config values in the application code?' Answer in 2-3 sentences."*

**Q5 (coûts/architecture)** — Tu dois choisir entre Parameter Store et Secrets Manager pour stocker le mot de passe d'une base de données RDS en production, avec une exigence de rotation automatique tous les 30 jours. Lequel choisis-tu et pourquoi ?

Correction du quiz.

### Q1 — ⚠️ Réponse trop superficielle, ne répond pas vraiment à la question
Tu décris ce qu'est Session Manager, mais tu n'expliques pas **le mécanisme technique** qui justifie l'absence de port entrant. La vraie réponse : l'agent SSM installé sur l'instance établit une **connexion sortante** vers le service AWS Systems Manager (comme n'importe quel appel API HTTPS sortant, port 443 en egress). Quand tu démarres une session depuis la console, AWS relaie la communication à travers ce tunnel déjà ouvert **depuis l'instance vers AWS**, jamais l'inverse. Résultat : aucune connexion entrante n'a besoin d'être acceptée par le Security Group — l'instance n'écoute jamais sur un port pour du trafic entrant SSH-like. C'est le même principe que si tu commandais quelque chose en ligne : le livreur ne rentre pas chez toi par effraction, c'est toi qui vas chercher le colis.
**Note : 4/10** — bonne intuition mais le "pourquoi" technique manque, c'est exactement ce que le recruteur veut entendre.

### Q2 — ⚠️ Définitions imprécises, la distinction n'est pas la bonne
Tu confonds la distinction. La vraie différence :
- **Management events** = actions sur le **plan de contrôle** de la ressource elle-même (créer, modifier, supprimer une ressource) — ex: `RunInstances`, `CreateVpc`, `AttachRolePolicy`. Activés par défaut.
- **Data events** = actions sur les **données à l'intérieur** d'une ressource — ex: `GetObject`/`PutObject` sur un objet S3, `Invoke` sur une fonction Lambda. Désactivés par défaut car le volume est énorme (chaque lecture/écriture de fichier, chaque invocation).

Exemple concret pour bien fixer : créer un bucket S3 (`CreateBucket`) = Management event. Télécharger un fichier depuis ce bucket (`GetObject`) = Data event.
**Note : 3/10** — la distinction proposée ("logs" vs "actions") n'est pas la bonne catégorisation, à retenir précisément car c'est une question classique.

### Q3 — ✅ Correct et bien formulé
Bonne réponse, claire et directe. Tu pourrais ajouter la précision technique : la correction se fait via `retention_in_days` sur la ressource `aws_cloudwatch_log_group` en Terraform, ou directement dans la console (Log Groups → Actions → Edit retention setting) — utile de savoir où ça se configure concrètement, pas juste "il faut la définir".
**Note : 8/10**

### Q4 (anglais) — ✅ Bon contenu, anglais correct
Solide, bien structuré, argument de sécurité pertinent (valeurs en dur = risque de vol si le code fuite, ex: repo Git public). Petite amélioration : mentionner aussi l'avantage opérationnel (changer une config sans redéployer le code) en plus du risque sécurité — c'est souvent l'argument principal en entretien, pas seulement la sécurité.

Version légèrement enrichie : *"Parameter Store lets you change configuration values without redeploying your application code, and it centralizes secrets outside your codebase — so if your repo leaks, credentials don't leak with it."*
**Note : 8/10** — net progrès sur la structure anglaise par rapport aux jours précédents, continue comme ça.

### Q5 — ✅ Correct et bien argumenté
Réponse directe, justification claire liée à l'exigence énoncée (rotation automatique). C'est exactement le type de réponse attendue : identifier le critère décisif (rotation native) plutôt que de lister toutes les différences entre les deux services.
**Note : 9/10**

---

### Score global quiz Jour 6 : **32/50 (64%)**

Bonne progression par rapport au Jour 4 (48%) — les questions à choix binaire avec justification claire (Q3, Q5) sont bien maîtrisées, et **ton anglais technique s'améliore nettement** (Q4). Les points faibles restent les définitions précises de mécanismes internes (Q1, Q2) — comprendre le "pourquoi ça marche" plutôt que "ce que ça fait". C'est un pattern qu'on va continuer à travailler.

---

**Question de simulation d'entretien (Cloud Engineer Senior) :**

*"Tu es en garde (on-call) et tu reçois une alerte CloudWatch : le CPU d'une instance derrière un ASG est à 95% depuis 20 minutes, mais l'ASG ne scale pas malgré une target tracking policy à 50%. Quelles sont tes hypothèses, et comment les vérifies-tu une par une ?"*

La démarche attendue, hypothèse par hypothèse

1. La policy scaling est-elle vraiment attachée et active ?
→ Console ASG → onglet "Automatic scaling" → vérifier que la target tracking policy existe, est Enabled, et cible bien la bonne métrique (ASGAverageCPUUtilization, pas une métrique custom mal configurée par erreur).

2. L'ASG a-t-il atteint son max_size ?
→ C'est l'hypothèse la plus fréquente et la plus souvent oubliée. Si desired_capacity a déjà atteint max_size, l'ASG ne peut physiquement pas ajouter d'instance, peu importe à quel point le CPU est haut. Vérifier : Console ASG → Desired, Min, Max actuels.

3. Le cooldown period bloque-t-il un nouveau scaling ?
→ Si un scale-in ou scale-out vient de se produire récemment, le cooldown peut empêcher une nouvelle action pendant quelques minutes. Vérifier : onglet "Activity" → dernière action de scaling et son timestamp.

4. La métrique CloudWatch remonte-t-elle vraiment ?
→ Vérifier directement dans CloudWatch → Metrics que ASGAverageCPUUtilization (pas juste le CPU d'une seule instance !) est bien au-dessus de 50% en moyenne sur toutes les instances de l'ASG — un piège classique : une seule instance à 95% peut être compensée par d'autres instances à 10%, donnant une moyenne ASG bien en dessous du seuil. Le target tracking se base sur la moyenne du groupe, pas sur une instance individuelle.

5. Y a-t-il un problème de permissions IAM sur le service-linked role de l'ASG ?
→ Rare mais possible : l'ASG utilise un rôle de service (AWSServiceRoleForAutoScaling) pour lancer des instances ; si ce rôle a été altéré, le scaling échoue silencieusement. Vérifier les événements d'erreur dans l'onglet "Activity".

6. Y a-t-il une limite de service AWS atteinte ?
→ Quota EC2 par type d'instance dans la région (ex: limite de vCPU on-demand atteinte) → l'ASG essaie de lancer une instance mais échoue. Vérifier : onglet "Activity" pour un message d'erreur explicite type InsufficientInstanceCapacity ou VcpuLimitExceeded

Le point clé à retenir (hypothèse n°4)

C'est le piège le plus important de cette question, et celui que tu n'as pas du tout mentionné : le CPU à 95% que tu observes est peut-être celui d'une seule instance, alors que le target tracking scale sur la moyenne du groupe entier. Une réponse senior doit immédiatement questionner : "95% sur quelle métrique exactement — l'instance individuelle ou la moyenne ASG ?", car ce sont deux choses différentes qui expliquent parfaitement pourquoi l'ASG ne réagit pas alors qu'une alerte a bien été déclenchée sur une instance précise.
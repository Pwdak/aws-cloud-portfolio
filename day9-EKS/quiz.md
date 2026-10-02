Excellent, labo Fargate complet et validé — image buildée et poussée sur ECR, cluster ECS en mode serverless (Fargate) opérationnel, 2 Tasks derrière un ALB, accès web confirmé via le DNS. Tu as maintenant vu concrètement la différence avec le Jour 3 : **aucune instance EC2 à gérer**, aucun patching, aucun Launch Template — juste une Task Definition et un Service qui orchestrent des conteneurs directement.

### Résumé Jour 8

- **ECS** : Cluster (regroupement logique, pas de control plane facturé séparément) → Task Definition (spec, versionnée) → Task (instance en exécution) → Service (maintient N tasks + intégration ALB, équivalent Deployment K8s)
- **Fargate** : serverless, paiement au vCPU/RAM/seconde, isolation forte par Task, pas d'accès SSH à l'hôte
- **ECR** : registre privé intégré IAM, `docker login` cible uniquement le registre (pas le repo), scan de vulnérabilités au push, lifecycle policies pour éviter l'accumulation de coûts
- **Target Group type `ip`** obligatoire pour Fargate (pas `instance`, contrairement au Jour 3)
- Le critère de décision ECS/Fargate vs EKS : simplicité + coût réduit à petite échelle vs portabilité multi-cloud + écosystème Kubernetes standard

---

### Quiz Jour 8

**Q1** — Pourquoi le Target Group d'un service ECS Fargate doit-il être configuré en `target_type = "ip"` et non `"instance"`, contrairement à ce qu'on avait fait au Jour 3 avec l'ASG ?

**Q2** — Tu remarques que ta facture ECR augmente chaque mois alors que tu ne stockes "que" quelques images. Quelle est la cause la plus probable, et comment la corriges-tu ?

**Q3 (en anglais)** — *"An interviewer asks: 'Your team already runs Kubernetes on-premise. Why would you still consider ECS for a new AWS-only project?' Answer in 2-3 sentences."*

**Q4** — Quelle est la différence fondamentale entre le rôle IAM utilisé par la Task Definition (`execution_role_arn` qu'on a configuré) et un éventuel rôle IAM que l'**application à l'intérieur du conteneur** utiliserait pour accéder à un bucket S3, par exemple ? (Indice : ce sont deux rôles différents avec deux responsabilités différentes)

**Q5 (coûts)** — Compare rapidement : pour une charge de travail avec un trafic très stable et prévisible 24/7, entre ECS sur EC2 (avec Reserved Instances) et ECS sur Fargate, lequel sera probablement le moins cher, et pourquoi ?

Réponds à ton rythme.
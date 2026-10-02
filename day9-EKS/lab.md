ECR : crée un repository, note l'URI.
Depuis ta machine (ou l'instance EC2 via Session Manager si Docker y est installé — sinon en local si tu as Docker) :
bash
   aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <account_id>.dkr.ecr.eu-west-1.amazonaws.com
   docker pull nginx:alpine
   docker tag nginx:alpine <account_id>.dkr.ecr.eu-west-1.amazonaws.com/mon-repo:latest
   docker push <account_id>.dkr.ecr.eu-west-1.amazonaws.com/mon-repo:latest
ECS : crée un cluster (mode Fargate), une Task Definition pointant vers ton image ECR (port 80), un Service avec 2 tasks désirées, associé à un ALB (comme au Jour 3, mais des Tasks au lieu d'EC2).

Parfait, pas besoin d'adapter. On repart sur ta base Terraform existante (VPC day6 avec subnet public) et on ajoute ECS/Fargate/ECR par-dessus — mais il nous faut un 2e subnet public (comme au Jour 3) puisque l'ALB devant le service ECS a besoin de 2 AZ minimum.

Étape 1 — Build et push de l'image (à faire maintenant, en parallèle du code Terraform)

Récupère ton Account ID :

bash
aws sts get-caller-identity --query Account --output text

On crée d'abord le repo ECR via Terraform (plus propre que de le créer à la main puis de l'importer). Nouveau fichier ecr.tf :

bash
terraform.exe apply
terraform.exe output -raw ecr_repository_url

Puis push l'image :

bash
$token = aws.exe ecr get-login-password --region eu-west-1
docker login --username AWS --password-stdin <account_id>.dkr.ecr.eu-west-1.amazonaws.com
docker pull nginx:alpine
docker tag nginx:alpine <ecr_repository_url>:latest
docker push <ecr_repository_url>:latest
Étape 2 — Réseau : ajouter le 2e subnet public

Dans main.tf, ajoute (adapte selon les variables déjà présentes dans ton variables.tf du Jour 6) :

Étape 3 — Nouveau fichier ecs.tf

⚠️ Remarque architecture (même remarque qu'au Jour 3) : les Tasks sont ici en subnet public avec assign_public_ip = true, pour simplifier le labo. En vraie prod, elles seraient en subnet privé (nécessitant un NAT Gateway pour que Fargate puisse pull l'image ECR, sauf si tu utilises un VPC Endpoint ECR — qu'on pourra explorer plus tard).

Exécution
bash
terraform.exe plan
terraform.exe apply

Une fois déployé, teste :

bash
curl http://$(terraform.exe output -raw ecs_alb_dns_name)

Tu dois voir la page par défaut de nginx:alpine. Va aussi dans la console ECS → Cluster → Service → Tasks pour observer les 2 Tasks Fargate en cours d'exécution (pas d'EC2 visible nulle part, c'est le point clé de Fargate).
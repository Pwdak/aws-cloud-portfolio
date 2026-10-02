🔧 Labo Jour 2 — Console AWS

Construis à la main un VPC minimal en 2-tier :

VPC : crée un VPC 10.0.0.0/16
Subnets :
subnet-public-1a : 10.0.1.0/24 en eu-west-1a (ou ta région)
subnet-private-1a : 10.0.2.0/24 en eu-west-1a
Internet Gateway : crée-le, attache-le au VPC
Route Tables :
rt-public : route 0.0.0.0/0 → IGW, associe-la à subnet-public-1a
rt-private : reste avec la route locale par défaut seulement, associe-la à subnet-private-1a
NAT Gateway : crée-le dans subnet-public-1a (avec une Elastic IP), puis ajoute une route 0.0.0.0/0 → NAT Gateway dans rt-private

Lance une EC2 dans subnet-private-1a (sans IP publique), une autre dans subnet-public-1a (avec IP publique, qui servira de bastion)
Connecte-toi en SSH sur le bastion public, puis en SSH depuis le bastion vers l'instance privée (tu devras copier ta clé ou utiliser SSH agent forwarding)
Depuis l'instance privée, teste curl -I https://google.com → doit fonctionner via le NAT Gateway
Vérifie que l'instance privée n'est pas joignable directement depuis ta machine

# COMMANDS
terraform init
terraform plan     # vérifie : 12 ressources à créer
terraform apply
ssh -i ta-clé.pem ec2-user@$(terraform output -raw bastion_public_ip)
# puis depuis le bastion :
ssh -i ta-clé.pem ec2-user@<private_ip affichée dans outputs>
terraform destroy

Résumé Jour 2
VPC = espace IP isolé régional, subnet = toujours mono-AZ
Public/privé d'un subnet = déterminé uniquement par sa route table (présence d'une route vers IGW)
NAT Gateway = sortie internet pour subnet privé, un par AZ en prod pour la HA
SG = stateful, allow only, niveau instance. NACL = stateless, allow+deny, niveau subnet, évalué par ordre de règle
Référencer un SG dans un autre SG > référencer une IP, pour la scalabilité et le principe de moindre privilège dynamique
Terraform : structure multi-fichiers (versions.tf, variables.tf, main.tf, ec2.tf, outputs.tf, tfvars), workflow init → plan → apply → destroy
🔧 Labo Jour 4 — Console puis Terrafor

S3 : crée un bucket, active le versioning, uploade un fichier texte, modifie-le et re-uploade → observe les 2 versions dans l'onglet "Versions". Supprime le fichier → observe que ça crée un "delete marker" plutôt qu'une suppression réelle (récupérable).
EBS : va sur ton instance existante (ou une nouvelle t2.nano), regarde le volume EBS attaché par défaut (root volume) → crée un snapshot manuel → observe le temps de création et son état "incrémental".
Route53 (si tu as un nom de domaine, sinon on peut le simuler autrement — dis-moi) : crée une Hosted Zone, ajoute un enregistrement de type Alias pointant vers ton ALB du Jour 3 (s'il tourne encore) → observe la résolution avec nslookup ou dig.


Test EFS validé — tu as maintenant vu de tes propres yeux la différence fondamentale entre EBS (bloc, exclusif à une instance) et EFS (fichier, partagé en temps réel entre plusieurs instances). C'est exactement le genre de démonstration concrète à raconter en entretien plutôt que de réciter la théorie : "J'ai testé le partage EFS entre deux instances dans des AZ différentes, écriture immédiatement visible des deux côtés" — ça sonne bien plus crédible qu'une définition apprise par cœur.

Résumé Jour 4
Route53 : Public vs Private Hosted Zone, routing policies (simple/weighted/latency/failover/geolocation), Alias record (spécifique AWS, fonctionne sur l'apex, gratuit en requêtes) vs CNAME (impossible sur l'apex)
EBS : disque bloc, lié à une AZ, attaché à une seule instance (sauf Multi-Attach io1/io2), snapshots incrémentaux
EFS : filesystem partagé, élastique, multi-AZ nativement via mount targets, cas d'usage = partage entre plusieurs instances
S3 : storage classes (Standard → IA → Glacier), durabilité (11 "9") ≠ disponibilité (99,99%), bucket policy (resource-based) + Block Public Access par défaut, versioning + lifecycle policies
Terraform : Private Hosted Zone sans domaine réel, ALB léger sans ASG (target_type instance direct), mount targets EFS multi-AZ

## COMMANDS 

ssh -i '..\..\Keys\engineer-lab.pem' ec2-user@$(terraform.exe output -raw lab_instance_public_ip)                                                                              
  17 terraform.exe output -raw efs_id                                                                                                                                               
  18 ssh -i '..\..\Keys\engineer-lab.pem' ec2-user@$(terraform.exe output -raw lab_instance_public_ip)
history
    1  hostname
    2  dig app.lab.internal
    3  ping app.lab.internal
    4  ping instance.lab.internal
    5  ip a
    6  ping app.lab.internal
    7  hostname
    8  ping instance.lab.internal
    9  ping app.lab.internal
   10  exit
   11  cat /var/www/html/index.html 
   14  dnf install dig -y
   15  sudo dnf install dig -y
   16  sudo dnf install bind-utils -y
   17  dig -v
   18  cat /var/www/html/index.html 
   19  curl app.lab.internal
   20  curl instance.lab.internal
   21  dig app.lab.internal
   22  dig instance.lab.internal
   23  ls
   24  sudo ls /
   25  sudo df -hT
   26  sudo lsblk
   28  sudo dnf install -y amazon-efs-utils
   29  sudo mkdir /mnt/efs
   30  exit
   31  sudo mount -t efs fs-075397b7ba18c5dc3:/ /mnt/efs
   33  sudo df -h
   34  sudo ls /mnt/efs/
   35  echo "test EFS" | sudo tee /mnt/efs/test.txt
   38  sudo cat /mnt/efs/test.txt 

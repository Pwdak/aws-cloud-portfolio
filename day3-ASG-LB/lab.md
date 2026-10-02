🔧 Labo Jour 3 — Console d'abord, puis Terraform

Crée un Launch Template : AMI Amazon Linux 2023, t3.micro, avec ce User Data pour bootstrap un mini serveur web de test :
bash
   #!/bin/bash
   dnf install -y httpd
   systemctl enable httpd
   systemctl start httpd
   echo "<h1>Instance $(hostname -f)</h1>" > /var/www/html/index.html
Crée un Target Group (HTTP, port 80, health check sur /)
Crée un ALB dans tes 2 subnets publics (⚠️ il te faudra un deuxième subnet public dans une autre AZ — l'ALB exige au moins 2 AZ ; si tu n'as que subnet-public-1a, ajoute un subnet-public-1b)
Crée l'Auto Scaling Group : min=2, desired=2, max=4, associé au Launch Template et au Target Group, health check type ELB
Attends que les 2 instances soient healthy dans le Target Group
Ouvre l'URL du DNS de l'ALB dans ton navigateur, rafraîchis plusieurs fois → tu dois voir alterner le hostname entre les 2 instances (load balancing en action)
Test de résilience : termine manuellement une instance depuis EC2 → observe l'ASG la recréer automatiquement en quelques minutes, et l'ALB router de nouveau correctement une fois healthy

Résumé Jour 3
EC2 : familles d'instances par usage, burstable (t) avec CPU credits, pricing models (On-Demand/Reserved/Savings Plans/Spot)
ASG : Launch Template + min/desired/max, health check type ELB > EC2 pour détecter les pannes applicatives, target tracking scaling
ALB (L7, routage HTTP intelligent, pas d'IP statique) vs NLB (L4, perf max, IP statique possible)
Instances applicatives derrière un ALB → toujours en subnet privé en prod, jamais exposées directement
Target Group + health checks = le mécanisme qui permet à l'ASG et à l'ALB de coopérer pour un remplacement transparent
Terraform : itération sur une codebase existante (ajout de fichiers, modification de variables), gestion du cycle de vie complet (create → update → destroy de ressources devenues obsolètes)
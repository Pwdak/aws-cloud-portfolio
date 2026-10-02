Quiz Jour 2 — Security Groups vs NACL (la question la plus posée en entretien réseau AWS)

Réponds à l'oral, comme si j'étais le recruteur :

Question 1 — Un client te dit : "J'ai un Security Group qui autorise le port 443 en inbound, mon NACL autorise aussi le port 443 en inbound, mais mon appli ne répond toujours pas depuis internet. Qu'est-ce qui pourrait manquer ?"

Question 2 — Pourquoi dit-on qu'un Security Group est "stateful" et qu'un NACL est "stateless" ? Donne un exemple concret où cette différence casse quelque chose si on l'ignore.

Question 3 — Peux-tu avoir un Security Group qui refuse explicitement un trafic (une règle "Deny") ? Pourquoi ou pourquoi pas ?

Question 4 — Dans ton labo d'aujourd'hui, sg-private autorise le SSH uniquement depuis sg-bastion (via security_groups = [...]) plutôt que depuis une IP en cidr_blocks. Quel est l'avantage de référencer un Security Group plutôt qu'une IP/CIDR ?


Q1 — ✅ Correct, avec une précision à ajouter

Bonne intuition. Pour être exhaustif à l'oral d'un recruteur senior : ce n'est pas juste "l'outbound manque" en général, c'est spécifiquement la règle outbound sur la plage des ports éphémères (1024–65535) qui doit être ouverte — car le trafic retour d'une requête HTTPS entrante repart depuis le port 443 (source) vers un port éphémère côté client, et c'est ce sens-là qu'il faut explicitement autoriser en sortie sur le NACL (le NACL par défaut autorise déjà tout, c'est un NACL custom qui pose souvent ce piège).
Note : 8/10

Q2 — ✅ Bonne compréhension du concept, exemple à ajouter

Ta définition est correcte. Ce qui manquait : un exemple concret, que je te donne : si un client externe initie une connexion sur le port 443 de ton serveur (autorisé en inbound sur le SG), la réponse sortante est automatiquement autorisée par le SG même si tu n'as aucune règle outbound explicite pour ça — c'est le "stateful". Sur un NACL, si tu n'as pas explicitement autorisé le port éphémère en outbound, cette même réponse sera bloquée, même si l'inbound 443 est ouvert — d'où le lien direct avec ta réponse Q1.
Note : 7/10

Q3 — ⚠️ Conclusion correcte, mais raisonnement à corriger

Ta conclusion (pas de Deny sur un SG) est juste, mais "déclaratif" n'est pas la bonne justification — un NACL est aussi déclaratif (on déclare des règles Allow ET Deny) et pourtant lui les supporte. La vraie raison est un choix de conception AWS : le Security Group est volontairement limité à un modèle whitelist pur (uniquement des Allow), avec un deny implicite par défaut pour tout ce qui n'est pas explicitement autorisé. C'est un choix délibéré pour garder les SG simples et lisibles au niveau instance ; la granularité "Deny explicite" est réservée au NACL, qui opère à un niveau plus large (subnet) où on veut parfois bloquer un range précis (ex: bannir une IP malveillante) sans toucher à des dizaines de SG.
Note : 5/10 — bonne conclusion, mauvaise justification, à retenir pour ne pas se faire piéger si le recruteur creuse "pourquoi ce choix de conception ?"

Q4 — ⚠️ Vrai mais ce n'est pas l'argument principal attendu

Le fait que l'IP change est vrai (et pertinent), mais l'avantage principal attendu en entretien est différent : en référençant security_groups = [aws_security_group.bastion.id] plutôt qu'un CIDR, la règle devient dynamique et suit le groupe, pas une IP figée. Concrètement :

Si tu ajoutes une deuxième instance bastion (scaling, HA multi-AZ) et qu'elle est aussi dans sg-bastion, elle est automatiquement autorisée à joindre sg-private sans toucher à la moindre règle.
Ça évite la maintenance manuelle de listes d'IP à chaque changement d'infra — c'est le principe de least privilege scalable : le contrôle d'accès suit une identité logique (le rôle "bastion"), pas une adresse réseau qui peut changer ou être partagée.
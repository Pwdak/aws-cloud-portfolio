# AWS Cloud Engineer — Learning Portfolio

Hands-on AWS infrastructure projects built with Terraform, as part of a structured
30-day AWS Cloud Engineer preparation program. Each folder is a self-contained
Terraform project covering a specific AWS domain.

## Projects

| Folder | Topic | Key services |
|---|---|---|
| day02-vpc-bastion | Multi-tier VPC, bastion pattern | VPC, IAM, EC2, NAT Gateway |
| day03-asg-alb | High-availability web tier | Auto Scaling, ALB, Launch Templates |
| day04-storage-dns | Storage & DNS | S3, EBS, EFS, Route53 |
| day06-monitoring-ssm | Observability & ops | CloudWatch, CloudTrail, Systems Manager |
| day07-kms-secrets | Encryption & secrets | KMS, Secrets Manager |
| day08-ecs-fargate | Serverless containers | ECS, Fargate, ECR |
| day09-eks | Managed Kubernetes | EKS, Managed Node Groups |
| day10-lambda | Serverless API | Lambda, API Gateway (HTTP API) |

## Stack
Terraform (modular, remote state on S3 + DynamoDB locking) · AWS · (CI/CD pipeline in progress)

## About
Built by Arnold Kouevi — DevOps & AWS Cloud Engineer.

output "lab_instance_public_ip" {
  value = aws_instance.lab.public_ip
}

output "lab_instance_2_public_ip" {
  value = aws_instance.lab_2.public_ip
}

output "alb_dns_name" {
  value = aws_lb.lite.dns_name
}

output "efs_id" {
  value = aws_efs_file_system.lab.id
}


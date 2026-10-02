output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "private_instance_ip" {
  value = aws_instance.private.private_ip
}

output "nat_gateway_public_ip" {
  value = aws_eip.nat.public_ip
}
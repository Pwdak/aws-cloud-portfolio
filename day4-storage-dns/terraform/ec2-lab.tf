# ---------- AMI Amazon Linux 2023 ----------
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# ---------- Security Group instance de test ----------
resource "aws_security_group" "lab_instance" {
  name        = "sgabInstance"
  description = "SSH depuis mon IP pour tests EBS/EFS"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "SSH depuis mon IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description     = "HTTP depuis ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_lite.id]
  }

  # NFS pour EFS (port 2049), uniquement depuis ce même SG
  ingress {
    description     = "NFS depuis ce SG (pour EFS)"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = null
    self            = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sgabInstance"
  }
}

# ---------- EC2 de test (pour EBS/EFS) ----------
resource "aws_instance" "lab" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.lab_instance.id]
  key_name                    = var.key_pair_name
  associate_public_ip_address = true

  tags = {
    Name = "ec2-lab-storage-test"
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf install -y httpd
    systemctl enable httpd
    systemctl start httpd
    echo "<h1>Route53 test instance</h1>" > /var/www/html/index.html
  EOF
  )

}

# ---------- EBS additionnel (volume séparé du root) ----------
resource "aws_ebs_volume" "data" {
  availability_zone = var.availability_zone
  size               = 5
  type               = "gp3"

  tags = {
    Name = "ebs-data-lab"
  }
}

resource "aws_volume_attachment" "data" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.lab.id
}
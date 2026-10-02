# ---------- AMI Amazon Linux 2023 la plus récente ----------
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# ---------- Security Group Bastion (public) ----------
resource "aws_security_group" "bastion" {
  name        = "sgbastion"
  description = "SSH depuis mon IP uniquement"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "SSH depuis mon IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sgbastion"
  }
}

# ---------- Security Group instance privée ----------
resource "aws_security_group" "private" {
  name        = "sgprivate"
  description = "SSH uniquement depuis le bastion"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description     = "SSH depuis le bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sgprivate"
  }
}

# ---------- EC2 Bastion (public) ----------
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  key_name                    = var.key_pair_name
  associate_public_ip_address = true

  tags = {
    Name = "ec2-bastion-public"
  }
}

# ---------- EC2 privée ----------
resource "aws_instance" "private" {
  ami                     = data.aws_ami.al2023.id
  instance_type           = var.instance_type
  subnet_id               = aws_subnet.private.id
  vpc_security_group_ids  = [aws_security_group.private.id]
  key_name                = var.key_pair_name

  tags = {
    Name = "ec2-private"
  }
}
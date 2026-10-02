resource "aws_security_group" "lab_instance_2" {
  name        = "sgabInstance-2"
  description = "SSH depuis mon IP - test EFS"
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

  tags = { Name = "sgabInstance-2" }
}

resource "aws_instance" "lab_2" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_2.id
  vpc_security_group_ids      = [aws_security_group.lab_instance_2.id]
  key_name                    = var.key_pair_name
  associate_public_ip_address = true

  tags = { Name = "ec2-lab-storage-test-2" }
}
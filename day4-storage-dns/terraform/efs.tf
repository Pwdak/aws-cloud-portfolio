resource "aws_security_group" "efs" {
  name        = "sgefs"
  description = "NFS depuis instance de test"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description     = "NFS depuis instance 1"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.lab_instance.id]
  }

  ingress {
    description     = "NFS depuis instance 2"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.lab_instance_2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "sg-efs" }
}

resource "aws_efs_file_system" "lab" {
  creation_token   = "efs-lab"
  encrypted         = true
  performance_mode  = "generalPurpose"
  throughput_mode   = "bursting"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = { Name = "efs-lab" }
}

# Mount target dans chaque subnet public (une AZ suffirait pour ce test,
# mais on illustre le multi-AZ pour rester réaliste)
resource "aws_efs_mount_target" "az1" {
  file_system_id  = aws_efs_file_system.lab.id
  subnet_id        = aws_subnet.public.id
  security_groups  = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "az2" {
  file_system_id  = aws_efs_file_system.lab.id
  subnet_id        = aws_subnet.public_2.id
  security_groups  = [aws_security_group.efs.id]
}
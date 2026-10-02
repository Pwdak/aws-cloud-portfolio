# ---------- VPC ----------
resource "aws_vpc" "lab" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-terraform-lab"
  }
}

# ---------- Subnets ----------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block               = var.public_subnet_cidr
  availability_zone        = var.availability_zone
  map_public_ip_on_launch  = true

  tags = {
    Name = "subnet-public-1a"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.lab.id
  cidr_block         = var.private_subnet_cidr
  availability_zone  = var.availability_zone

  tags = {
    Name = "subnet-private-1a"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block               = var.public_subnet_2_cidr
  availability_zone        = var.availability_zone_2
  map_public_ip_on_launch  = true

  tags = {
    Name = "subnet-public-1b"
  }
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.lab.id
  cidr_block         = var.private_subnet_2_cidr
  availability_zone  = var.availability_zone_2

  tags = {
    Name = "subnet-private-1b"
  }
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

# ---------- Internet Gateway ----------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name = "igw-lab"
  }
}

# ---------- NAT Gateway (+ Elastic IP) ----------
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "eip-nat-lab"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "natgw-lab"
  }

  depends_on = [aws_internet_gateway.igw]
}

# ---------- Route Table publique ----------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "rt-public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ---------- Route Table privée ----------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "rt-private"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
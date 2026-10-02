# ---------- Security Group pour l'ALB ----------
resource "aws_security_group" "alb" {
  name        = "sgalb"
  description = "HTTP depuis internet"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "HTTP depuis internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sgalb"
  }
}

# ---------- Security Group des instances applicatives ----------
resource "aws_security_group" "app" {
  name        = "sgapp"
  description = "HTTP depuis ALB uniquement"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description     = "HTTP depuis ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sgapp"
  }
}

# ---------- AMI Amazon Linux 2023 la plus récente ----------
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# ---------- Launch Template ----------
resource "aws_launch_template" "app" {
  name_prefix   = "lt-app-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf install -y httpd
    systemctl enable httpd
    systemctl start httpd
    echo "<h1>Instance $(hostname -f)</h1>" > /var/www/html/index.html
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ec2-app-asg"
    }
  }
}

# ---------- Target Group ----------
resource "aws_lb_target_group" "app" {
  name     = "tg-app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.lab.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 15
    timeout             = 5
    matcher             = "200"
  }

  deregistration_delay = 30

  tags = {
    Name = "tg-app"
  }
}

# ---------- Application Load Balancer ----------
resource "aws_lb" "app" {
  name               = "alb-app-lab"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public.id, aws_subnet.public_2.id]

  tags = {
    Name = "alb-app-lab"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port               = 80
  protocol           = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ---------- Auto Scaling Group ----------
resource "aws_autoscaling_group" "app" {
  name                = "asgapp-lab"
  min_size            = var.asg_min_size
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  vpc_zone_identifier = [aws_subnet.private.id, aws_subnet.private_2.id]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 60

  tag {
    key                 = "Name"
    value               = "ec2-app-asg"
    propagate_at_launch = true
  }
}
# ---------- Target Tracking Scaling Policy ----------
resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "asg-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type             = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
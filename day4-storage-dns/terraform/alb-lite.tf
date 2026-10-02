resource "aws_security_group" "alb_lite" {
  name        = "sgalbLite"
  description = "HTTP depuis internet - test Route53"
  vpc_id      = aws_vpc.lab.id

  ingress {
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

  tags = { Name = "sgalbLite" }
}

resource "aws_lb" "lite" {
  name               = "alb-route53-test"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_lite.id]
  subnets            = [aws_subnet.public.id, aws_subnet.public_2.id]

  tags = { Name = "alb-route53-test" }
}

resource "aws_lb_target_group" "lite" {
  name        = "tg-route53-test"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.lab.id
  target_type = "instance"

  health_check {
    path     = "/"
    protocol = "HTTP"
    matcher  = "200"
  }
}

resource "aws_lb_target_group_attachment" "lite" {
  target_group_arn = aws_lb_target_group.lite.arn
  target_id         = aws_instance.lab.id
  port               = 80
}

resource "aws_lb_listener" "lite" {
  load_balancer_arn = aws_lb.lite.arn
  port               = 80
  protocol           = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lite.arn
  }
}
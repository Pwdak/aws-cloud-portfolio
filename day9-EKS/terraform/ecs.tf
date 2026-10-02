# ---------- Cluster ECS ----------
resource "aws_ecs_cluster" "lab" {
  name = "cluster-day8-lab"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = { Name = "cluster-day8-lab" }
}

# ---------- Rôle d'exécution (pull image ECR, écrire logs) ----------
resource "aws_iam_role" "ecs_execution" {
  name = "role-ecs-execution-day8"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ---------- Log group ----------
resource "aws_cloudwatch_log_group" "ecs_app" {
  name              = "/ecs/day8-app"
  retention_in_days = 7
}

# ---------- Task Definition ----------
resource "aws_ecs_task_definition" "app" {
  family                   = "task-day8-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                       = "256"
  memory                    = "512"
  execution_role_arn        = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([{
    name      = "app"
    image     = "${aws_ecr_repository.app.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 80
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs_app.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

# ---------- Security Groups ----------
resource "aws_security_group" "alb_ecs" {
  name   = "sgalbecsday8"
  vpc_id = aws_vpc.lab.id

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

  tags = { Name = "sgalbecsday8" }
}

resource "aws_security_group" "ecs_tasks" {
  name   = "sgecstasksday8"
  vpc_id = aws_vpc.lab.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "sgecstasksday8" }
}

# ---------- ALB ----------
resource "aws_lb" "ecs" {
  name               = "alb-ecs-day8"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_ecs.id]
  subnets            = [aws_subnet.public.id, aws_subnet.public_2.id]

  tags = { Name = "alb-ecs-day8" }
}

resource "aws_lb_target_group" "ecs" {
  name        = "tg-ecs-day8"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.lab.id
  target_type = "ip"   # obligatoire pour Fargate (pas "instance")

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "ecs" {
  load_balancer_arn = aws_lb.ecs.arn
  port               = 80
  protocol           = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
}

# ---------- Service ECS ----------
resource "aws_ecs_service" "app" {
  name            = "service-day8-app"
  cluster         = aws_ecs_cluster.lab.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public.id, aws_subnet.public_2.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true   # nécessaire car les tasks sont en subnet public
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs.arn
    container_name    = "app"
    container_port     = 80
  }

  depends_on = [aws_lb_listener.ecs]
}

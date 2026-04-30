resource "aws_ecr_repository" "flask_repo" { name = "flask-backend" }
resource "aws_ecr_repository" "express_repo" { name = "express-frontend" }
resource "aws_vpc" "ecs_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" { vpc_id = aws_vpc.ecs_vpc.id }

resource "aws_subnet" "subnet_a" {
  vpc_id = aws_vpc.ecs_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
}

resource "aws_subnet" "subnet_b" {
  vpc_id = aws_vpc.ecs_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
}
resource "aws_lb" "main_alb" {
  name               = "app-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
}

resource "aws_lb_target_group" "express_tg" {
  name = "express-tg"
  port = 3000
  protocol = "HTTP"
  vpc_id = aws_vpc.ecs_vpc.id
  target_type = "ip"
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.main_alb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.express_tg.id
  }
}
resource "aws_ecs_cluster" "main_cluster" { name = "app-cluster" }

resource "aws_ecs_task_definition" "app_task" {
  family                   = "app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_exec_role.arn

  container_definitions = jsonencode([
    {
      name  = "express-app"
      image = "${aws_ecr_repository.express_repo.repository_url}:latest"
      portMappings = [{ containerPort = 3000 }]
    }
  ])
}

resource "aws_ecs_service" "express_service" {
  name            = "express-service"
  cluster         = aws_ecs_cluster.main_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [aws_subnet.subnet_a.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.express_tg.id
    container_name   = "express-app"
    container_port   = 3000
  }
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_exec_role" {
  name = "ecs_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_exec_attachment" {
  role       = aws_iam_role.ecs_exec_role.name
  # Change the ARN to this:
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Security Group for ALB (Public Port 80)
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.ecs_vpc.id
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
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.ecs_vpc.id
  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "task_definition_path" {
  description = "Path to the task definition JSON file"
  type        = string
}

resource "aws_ecs_cluster" "nbc-lab" {
  name = "nbc-lab-cluster"
}

resource "aws_lb" "nbc-lab" {
  name               = "nbc-lab-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.nbc-lab.id]
}

resource "aws_cloudwatch_log_group" "nbc-lab" {
  name = "/ecs/nbc-lab"
}

resource "aws_lb_target_group" "nbc-lab" {
  name        = "nbc-lab-target-group"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "nbc-lab" {
  load_balancer_arn = aws_lb.nbc-lab.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.nbc-lab.arn
    type             = "forward"
  }
}

resource "aws_ecs_service" "nbc-lab" {
  name            = "nbc-lab-service"
  cluster         = aws_ecs_cluster.nbc-lab.id
  task_definition = aws_ecs_task_definition.nbc-lab.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.nbc-lab.id]
    subnets         = var.private_subnet_ids
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nbc-lab.arn
    container_name   = "nbc-lab-container"
    container_port   = 8080
  }
}

resource "aws_ecs_task_definition" "nbc-lab" {
  family                   = "nbc-lab-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.nbc-lab.arn

  container_definitions = file(var.task_definition_path)
}

resource "aws_iam_role" "nbc-lab" {
  name = "nbc-lab-ecs-task-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_task_role_policy" {
  role   = aws_iam_role.nbc-lab.name
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "secretsmanager:GetSecretValue",
        "Resource": "arn:aws:secretsmanager:us-west-1:155009719402:secret:dev/mysql/cred-MPSO4k"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "nbc-lab-ecs-task-policy-attachment" {
  role       = aws_iam_role.nbc-lab.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_security_group" "nbc-lab" {
  name        = "nbc-lab-security-group"
  description = "nbc-lab Security Group"

  vpc_id = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
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

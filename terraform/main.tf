provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "logstash_cluster" {
  name = "logstash-cluster"
}
resource "aws_ecr_repository" "logstash_repo" {
  name                 = "logstash-repo"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecs_task_definition" "logstash" {
  family                   = "logstash"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "logstash"
      image     = "${aws_ecr_repository.logstash_repo.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 5044
          hostPort      = 5044
          protocol      = "tcp"
        },
      ]
    },
  ])
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = "runner"
      },
    ]
  })
}

resource "aws_ecs_service" "logstash_service" {
  name            = "logstash-service"
  cluster         = aws_ecs_cluster.logstash_cluster.id
  task_definition = aws_ecs_task_definition.logstash.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-xxxxxx"]
    security_groups  = ["sg-xxxxxx"]
    assign_public_ip = true
  }
}


# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "ecs-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "ecs-cicd-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  container_definitions    = jsonencode([
    {
      name      = "ecs-cicd-app"
      image     = "${aws_ecr_repository.app.repository_url}:1"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "app" {
  name            = "ecs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public.id]
    security_groups = [aws_security_group.jenkins_sg.id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.app]
}
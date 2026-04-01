resource "aws_ecr_repository" "app" {
  name                 = "ecs-cicd-app"
  image_tag_mutability = "IMMUTABLE"
  tags = { Environment = "production" }
}
resource "aws_ecr_repository" "demo_app" {
  name                 = "demo-app"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}
output "ecr_repository_url" {
  value = aws_ecr_repository.demo_app.repository_url
}

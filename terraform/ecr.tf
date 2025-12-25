resource "aws_ecr_repository" "backend" {
  name = "${var.project}-backend"

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "IMMUTABLE"
}


resource "aws_ecr_repository" "repo" {
  for_each               = toset(var.repositories)
  name                   = each.value
  image_tag_mutability   = var.image_tag_immutability
  image_scanning_configuration { scan_on_push = var.scan_on_push }
  tags = var.tags
}

# 최근 50개 Tag만 보존, 없는 Tag Image 정리(임시로 내맘대로 정책...)
resource "aws_ecr_lifecycle_policy" "gc" {
  for_each    = aws_ecr_repository.repo
  repository  = each.value.name
  policy      = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Untagged cleanup",
        selection    = { tagStatus = "untagged", countType = "sinceImagePushed", countUnit = "days", countNumber = 14 },
        action       = { type = "expire" }
      },
      {
        rulePriority = 2,
        description  = "Keep recent 50 tags",
        selection    = { tagStatus = "tagged", tagPrefixList = [""], countType = "imageCountMoreThan", countNumber = 50 },
        action       = { type = "expire" }
      }
    ]
  })
}

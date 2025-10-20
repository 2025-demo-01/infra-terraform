output "karpenter_security_group_id" { value = aws_security_group.karpenter_shared.id }
output "private_subnet_ids"          { value = var.private_subnet_ids }
output "public_subnet_ids"           { value = var.public_subnet_ids }

locals {
  tags = merge({
    project = "upx-exchange"
    owner   = "platform"
  }, var.tags)
}

# 카펜터/ALB용 보안그룹 (태그만 필요해도 SG 하나 만들어 공유하는 편이 깔끔함)
resource "aws_security_group" "karpenter_shared" {
  name        = "${var.name}-karpenter-sg"
  description = "Shared SG for Karpenter nodes and workloads"
  vpc_id      = var.vpc_id
  tags        = merge(local.tags, { karpenter = "enabled" })
}

# 서브넷/SG에 카펜터 탐지 태그 부여
resource "aws_ec2_tag" "private_subnet_tags" {
  for_each    = toset(var.private_subnet_ids)
  resource_id = each.key
  key         = "karpenter"
  value       = "enabled"
}

resource "aws_ec2_tag" "public_subnet_tags" {
  for_each    = toset(var.public_subnet_ids)
  resource_id = each.key
  key         = "karpenter"
  value       = "enabled"
}

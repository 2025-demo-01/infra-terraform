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

# modules/network/main.tf (추가, 간단 예시)
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [] # 해당 VPC RT로 채워 넣기
  tags = local.tags
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.private_subnet_ids
  security_group_ids= [aws_security_group.karpenter_shared.id]
  private_dns_enabled = true
  tags = local.tags
}
# (ecr.dkr, sts, logs, kms, ssm, secretsmanager 등도 동일 패턴)

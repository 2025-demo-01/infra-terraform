# Interface Endpoints용 SG (443 허용)
resource "aws_security_group" "endpoints" {
  name        = "${var.name_prefix}-vpce-sg"
  description = "SG for VPC Interface Endpoints"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.endpoints.id
  cidr_blocks       = var.allowed_cidrs
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.endpoints.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# --------- Gateway Endpoints ---------
resource "aws_vpc_endpoint" "s3" {
  count             = var.create_gateway_s3 ? 1 : 0
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var._private_route_table_ids
  tags              = var.tags
}

resource "aws_vpc_endpoint" "dynamodb" {
  count             = var.create_gateway_dynamodb ? 1 : 0
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var._private_route_table_ids
  tags              = var.tags
}

# --------- Interface Endpoints (핵심 세트) ---------
locals {
  interface_services = [
    "ecr.api",
    "ecr.dkr",
    "sts",
    "ssm",
    "ssmmessages",
    "ec2",
    "logs",
    "monitoring",      # CloudWatch
    "kms",
    "secretsmanager"
  ]
}

resource "aws_vpc_endpoint" "iface" {
  for_each            = toset(local.interface_services)
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true
  tags                = var.tags
}

# 내부 route table id 가져오려면, env에서 variable로 넘기거나 data로 조회
# 여기서는 간단화를 위해 env에서 넘긴다고 가정
variable "_private_route_table_ids" {
  type = list(string)
  default = []
}

data "aws_region" "current" {}

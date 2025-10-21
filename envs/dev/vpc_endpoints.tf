module "vpc_endpoints" {
  source               = "../../modules/vpc-endpoints"
  name_prefix          = var.name_prefix
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  allowed_cidrs        = [var.vpc_cidr]  # 내부만 접근 허용
  _private_route_table_ids = try(module.vpc.private_route_table_ids, [])
  create_gateway_s3    = true
  create_gateway_dynamodb = false
  tags                 = local.tags
}

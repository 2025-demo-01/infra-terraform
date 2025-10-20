module "network" {
  source              = "../../modules/network"
  name                = "upx-prod"
  region              = var.region
  vpc_id              = var.vpc_id
  private_subnet_ids  = var.private_subnet_ids
  public_subnet_ids   = var.public_subnet_ids
  tags                = var.tags
}

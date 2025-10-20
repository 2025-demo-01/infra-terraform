module "aurora" {
  source          = "../../modules/aurora"
  name            = "upx-aurora-dev"
  engine          = var.aurora_engine
  engine_version  = var.aurora_engine_version
  vpc_id          = var.vpc_id
  subnet_ids      = module.network.private_subnet_ids
  master_username = var.aurora_master_user
  master_password = var.aurora_master_pass
  tags            = var.tags
}

module "arc" {
  source          = "../../modules/route53-arc"
  name_prefix     = var.name_prefix
  control_regions = ["ap-northeast-2","us-west-2"]
  tags            = local.tags
}

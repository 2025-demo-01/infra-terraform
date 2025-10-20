module "dr" {
  source             = "../../modules/dr"
  hosted_zone        = var.domain_root
  primary_record     = var.primary_record
  secondary_record   = var.dr_secondary_record
  primary_alb_arn    = var.primary_alb_arn
  secondary_alb_arn  = var.secondary_alb_arn
  hc_primary_path    = "/healthz"
  hc_secondary_path  = "/healthz"
  tags               = var.tags
}

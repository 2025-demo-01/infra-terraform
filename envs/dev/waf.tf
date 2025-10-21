data "aws_lb" "public_alb" {
  name = "${var.name_prefix}-public-alb"   
}

module "waf_shield" {
  source                = "../../modules/waf-shield"
  name_prefix           = var.name_prefix
  alb_arn               = data.aws_lb.public_alb.arn
  enable_bot_control    = false         # 유료 – 필요 시 true
  enable_rate_limit     = true
  rate_limit            = 2000
  enable_logging        = true
  log_bucket_name       = null          # null이면 모듈이 생성
  enable_shield_advanced = false        # 계정 구독 후 true
  route53_zone_id       = null          # R53 보호 원하면 Hosted Zone ID 입력
  tags                  = local.tags
}

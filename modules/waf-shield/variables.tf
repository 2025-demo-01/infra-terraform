variable "name_prefix" {}
variable "alb_arn" {}                  # ALB ARN (WAF는 NLB 불가)
variable "enable_bot_control" { type = bool, default = false }   # 유료
variable "enable_rate_limit"  { type = bool, default = true }
variable "rate_limit"         { type = number, default = 2000 }  # req/5min per IP

variable "enable_shield_advanced" { type = bool, default = false }  # 계정이 SA 구독 상태여야 동작
variable "route53_zone_id"        { type = string, default = null }  # (선택) Zone도 보호

variable "enable_logging"    { type = bool, default = true }
variable "log_bucket_name"   { type = string, default = null }  # null이면 새로 생성
variable "tags"              { type = map(string), default = {} }

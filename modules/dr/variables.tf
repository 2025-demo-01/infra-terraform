variable "hosted_zone"      { type = string } # example: "upx.exchange"
variable "primary_record"   { type = string } # "api.upx.exchange"
variable "secondary_record" { type = string } # "api-dr.upx.exchange"
variable "primary_alb_arn"  { type = string }
variable "secondary_alb_arn"{ type = string }
variable "hc_primary_path"  { type = string default = "/healthz" }
variable "hc_secondary_path"{ type = string default = "/healthz" }
variable "tags"             { type = map(string) default = {} }

variable "region"          { type = string  default = "ap-northeast-2" }
variable "cluster_name"    { type = string  default = "upx-eks-prod-apne2" }
variable "vpc_id"          { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "public_subnet_ids"  { type = list(string) }
variable "karpenter_version"  { type = string default = "v0.37.0" }
variable "kubernetes_version" { type = string default = "1.29" }
variable "tags"              { type = map(string) default = { "env" = "prod" } }

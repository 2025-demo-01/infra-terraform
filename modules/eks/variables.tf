variable "cluster_name"        { type = string }
variable "region"              { type = string }
variable "vpc_id"              { type = string }
variable "private_subnet_ids"  { type = list(string) }
variable "public_subnet_ids"   { type = list(string) }
variable "kubernetes_version"  { type = string default = "1.29" }
variable "system_instance_types" { type = list(string) default = ["m6i.large"] }
variable "system_min_size"     { type = number default = 2 }
variable "system_max_size"     { type = number default = 6 }
variable "oidc_provider_arn"   { type = string }
variable "tags"                { type = map(string) default = {} }
variable "enable_secrets_encryption" { type = bool   default = true }
variable "cluster_log_types"         { type = list(string) default = ["api","audit","authenticator","controllerManager","scheduler"] }
variable "kms_key_arn"               { type = string default = "" }

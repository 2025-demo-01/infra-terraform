variable "cluster_name" {}
variable "cluster_oidc_provider_arn" {}
variable "private_subnet_ids" { type = list(string) }
variable "security_group_ids" { type = list(string) }
variable "instance_families"  { type = list(string) }
variable "tags" { type = map(string), default = {} }

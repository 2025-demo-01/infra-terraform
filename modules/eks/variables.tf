variable "cluster_name" { type = string }
variable "region"       { type = string }
variable "vpc_id"       { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "public_subnet_ids"  { type = list(string) }
variable "tags"         { type = map(string) default = {} }
variable "kubernetes_version" { type = string default = "1.29" }

variable "system_instance_types" { type = list(string) default = ["m6i.large"] }
variable "system_min_size"       { type = number default = 2 }
variable "system_max_size"       { type = number default = 6 }

variable "enable_cluster_autoscaler" { type = bool default = false } # Karpenter 위주로 운영
variable "oidc_provider_arn" { type = string }

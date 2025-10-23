variable "name_prefix" {}
variable "version" {}
variable "vpc_id" {}
variable "private_subnet_ids" { type = list(string) }
variable "public_subnet_ids"  { type = list(string) }
variable "node_instance_types" { type = list(string) }
variable "tags" { type = map(string), default = {} }
variable "private_subnets" { type = list(string) }
variable "worker_ami_id"   { type = string }


variable "name_prefix" {}
variable "engine" {}
variable "engine_version" {}
variable "instance_class" {}
variable "subnet_ids" { type = list(string) }
variable "vpc_id" {}
variable "tags" { type = map(string), default = {} }

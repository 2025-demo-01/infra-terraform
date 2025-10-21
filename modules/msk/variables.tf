variable "name_prefix" {}
variable "vpc_id" {}
variable "subnet_ids" { type = list(string) }
variable "kafka_version" {}
variable "tags" { type = map(string), default = {} }

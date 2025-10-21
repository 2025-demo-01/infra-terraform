variable "name_prefix" {}
variable "cidr_block" {}
variable "public_subnets"  { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "tags"            { type = map(string), default = {} }

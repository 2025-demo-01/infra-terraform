variable "name"            { type = string }
variable "engine"          { type = string default = "aurora-mysql" }
variable "engine_version"  { type = string }
variable "vpc_id"          { type = string }
variable "subnet_ids"      { type = list(string) }
variable "master_username" { type = string default = "admin" }
variable "master_password" { type = string default = "sophielog" }
variable "tags"            { type = map(string) default = {} }

variable "cluster_name"     { type = string }
variable "region"           { type = string }
variable "vpc_id"           { type = string }
variable "subnet_ids"       { type = list(string) }
variable "kafka_version"    { type = string default = "3.6.0" }
variable "brokers_per_az"   { type = number default = 2 }
variable "sasl_username"    { type = string default = "sophielog" }
variable "sasl_password"    { type = string default = "sophielog" }
variable "tags"             { type = map(string) default = {} }
variable "client_security_group_id" { type = string } 

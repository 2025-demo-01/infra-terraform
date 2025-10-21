variable "root_domain" {}
variable "failover_enable" { type = bool }
variable "tags" { type = map(string), default = {} }

variable "namespace"    { type = string }
variable "cluster_name" { type = string }
variable "currency"     { type = string default = "USD" }
variable "tags"         { type = map(string) default = {} }

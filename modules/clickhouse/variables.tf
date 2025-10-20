variable "namespace"           { type = string }
variable "replicas"            { type = number default = 3 }
variable "storage_size"        { type = string default = "500Gi" }
variable "zookeeper_endpoints" { type = list(string) default = [] }
variable "tags"                { type = map(string) default = {} }

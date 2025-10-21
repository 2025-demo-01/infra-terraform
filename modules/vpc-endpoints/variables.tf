variable "name_prefix" {}
variable "vpc_id" {}
variable "private_subnet_ids" { type = list(string) }

variable "allowed_cidrs" { type = list(string) }

variable "create_gateway_s3" { type = bool, default = true }
variable "create_gateway_dynamodb" { type = bool, default = false }

variable "tags" { type = map(string), default = {} }

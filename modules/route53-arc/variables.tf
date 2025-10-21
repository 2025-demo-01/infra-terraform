variable "name_prefix" {}
variable "control_regions" { type = list(string) } # 예: ["ap-northeast-2","us-west-2"]
variable "tags" { type = map(string), default = {} }

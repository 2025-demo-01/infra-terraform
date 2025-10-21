variable "repositories" {
  type = list(string)
}
variable "image_tag_immutability" { type = string, default = "IMMUTABLE" } # or MUTABLE
variable "scan_on_push" { type = bool, default = true }
variable "tags" { type = map(string), default = {} }

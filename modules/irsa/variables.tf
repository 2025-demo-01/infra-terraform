variable "cluster_name" {}
variable "cluster_oidc_provider_arn" {}
variable "roles" {
  type = map(object({
    namespace        = string
    service_account  = string
    policy_json_path = string
  }))
}
variable "tags" { type = map(string), default = {} }

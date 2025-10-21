package main

deny[msg] {
  input.resource_type == "aws_security_group_rule"
  input.cidr_blocks[_] == "0.0.0.0/0"
  not input.allowed
  msg := "public ingress is not allowed"
}

deny[msg] {
  input.resource_type == "aws_instance"
  not input.metadata_options.http_tokens
  msg := "IMDSv2 must be required"
}

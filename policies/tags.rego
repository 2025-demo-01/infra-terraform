package main

deny[msg] {
  input.resource_type != ""
  required := {"env", "owner", "part_of"}
  missing := {k | k := required[_]; not input.tags[k]}
  count(missing) > 0
  msg := sprintf("missing required tags: %v", [missing])
}

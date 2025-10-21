output "security_group_id" { value = aws_security_group.endpoints.id }
output "interface_endpoint_ids" { value = [for v in aws_vpc_endpoint.iface : v.id] }
output "s3_endpoint_id" { value = try(aws_vpc_endpoint.s3[0].id, null) }
output "dynamodb_endpoint_id" { value = try(aws_vpc_endpoint.dynamodb[0].id, null) }

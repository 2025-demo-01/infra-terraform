output "cluster_id"       { value = aws_eks_cluster.this.id }
output "cluster_name"     { value = aws_eks_cluster.this.name }
output "cluster_arn"      { value = aws_eks_cluster.this.arn }
output "cluster_endpoint" { value = aws_eks_cluster.this.endpoint }
output "cluster_ca"       { value = aws_eks_cluster.this.certificate_authority[0].data }
output "nodegroup_role_name" { value = aws_iam_role.ng.name }

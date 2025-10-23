# modules/eks/nodegroup_perf.tf
resource "aws_eks_node_group" "perf" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "perf"
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids      = var.private_subnets

  instance_types  = ["c6i.4xlarge"]
  ami_type        = "AL2_x86_64"

  labels = {
    nodepool = "perf"                  # [ADDED]
  }

  taint {                              # [ADDED]
    key    = "workload"
    value  = "hotpath"
    effect = "NO_SCHEDULE"
  }

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 10
  }

  update_config { max_unavailable = 1 }

  lifecycle { ignore_changes = [scaling_config[0].desired_size] }
}

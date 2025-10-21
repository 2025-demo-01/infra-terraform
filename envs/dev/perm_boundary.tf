module "perm_boundary" {
  source        = "../../modules/perm-boundary"
  name          = "${var.name_prefix}-boundary"
  allowed_tags  = { env = "dev" }
}

resource "aws_iam_role" "devops" {
  name               = "${var.name_prefix}-devops"
  assume_role_policy = data.aws_iam_policy_document.devops_assume.json
  permissions_boundary = module.perm_boundary.policy_arn
  tags = local.tags
}
data "aws_iam_policy_document" "devops_assume" {
  statement { actions=["sts:AssumeRole"], principals{ type="AWS", identifiers=["*"] } }
}


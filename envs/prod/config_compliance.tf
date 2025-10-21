resource "aws_config_configuration_recorder" "main" {
  name     = "default"
  role_arn = aws_iam_role.config.arn
  recording_group { all_supported = true, include_global_resource_types = true }
}

resource "aws_config_delivery_channel" "main" {
  name           = "default"
  s3_bucket_name = aws_s3_bucket.audit.id
}

resource "aws_iam_role" "config" {
  name = "${var.name_prefix}-config-role"
  assume_role_policy = data.aws_iam_policy_document.config_assume.json
}
data "aws_iam_policy_document" "config_assume" {
  statement { actions = ["sts:AssumeRole"], principals { type="Service", identifiers=["config.amazonaws.com"] } }
}
resource "aws_iam_role_policy_attachment" "config_attach" {
  role = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

resource "aws_config_config_rule" "s3_public" {
  name = "s3-bucket-public-read-prohibited"
  source { owner = "AWS" source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED" }
}
resource "aws_config_config_rule" "imds_v2" {
  name = "ec2-imdsv2-check"
  source { owner = "AWS" source_identifier = "EC2_IMDSV2_CHECK" }
}

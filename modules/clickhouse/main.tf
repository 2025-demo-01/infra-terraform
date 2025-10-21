############################
# Amazon Managed Service for ClickHouse (지원 region/Provider version 필요)
# 사용 불가 region/version이면 "external endpoint 전달" 모드로 전환
############################

variable "use_managed_clickhouse" {
  type    = bool
  default = false
}

# (A) Managed ClickHouse – 지원 시 Active
resource "aws_clickhouse_cluster" "this" {
  count      = var.use_managed_clickhouse ? 1 : 0
  cluster_id = "${var.name_prefix}-ch"
  # 실제 Field들은 AWS Provider Version에 따라 상이하기 떄문에 제공 region/version 확인 필수.
  # 여기서는 endpoint 출력만을 목적으로 한 스텁입니다.
  tags = var.tags
}

# (B) 외부 ClickHouse(자체 운영) – Route53 또는 변수로 전달
# 가장 단순한 방식: "ch.<name_prefix>.local" 같은 내부 도메인을 사용한다고 가정
resource "aws_route53_zone" "stub" {
  count = var.use_managed_clickhouse ? 0 : 1
  name  = "${var.name_prefix}.local"
  tags  = var.tags
}

resource "aws_route53_record" "stub_endpoint" {
  count   = var.use_managed_clickhouse ? 0 : 1
  zone_id = aws_route53_zone.stub[0].zone_id
  name    = "clickhouse.${var.name_prefix}.local"
  type    = "CNAME"
  ttl     = 60
  records = ["ch.example.internal"] # 실제 endpoint로 교체
  depends_on = [aws_route53_zone.stub]
}

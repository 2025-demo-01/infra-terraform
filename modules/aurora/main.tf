############################
# Aurora PostgreSQL 
############################

resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-aurora-subnet"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "aurora" {
  name   = "${var.name_prefix}-aurora-sg"
  vpc_id = var.vpc_id
  tags   = var.tags
}

resource "aws_rds_cluster" "this" {
  cluster_identifier = "${var.name_prefix}-aurora"
  engine             = var.engine                        # e.g. "aurora-postgresql"
  engine_version     = var.engine_version                # e.g. "15.4"
  database_name      = "app"
  master_username    = "postgres"
  master_password    = "ChangeMe_123!"                   # 실제는 Secrets Manager 연동 권장
  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.aurora.id]
  storage_encrypted  = true
  backup_retention_period = 1
  tags = var.tags
}

resource "aws_rds_cluster_instance" "writer" {
  identifier         = "${var.name_prefix}-aurora-writer"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = var.instance_class                # e.g. "db.r6g.large"
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version
  publicly_accessible = false
  tags = var.tags
}

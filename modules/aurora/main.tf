locals {
  tags = merge({
    project = "upx-exchange"
    owner   = "data-platform"
  }, var.tags)
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnets"
  subnet_ids = var.subnet_ids
  tags       = local.tags
}

resource "aws_rds_cluster" "this" {
  cluster_identifier      = var.name
  engine                  = var.engine
  engine_mode             = "provisioned"
  engine_version          = var.engine_version
  master_username         = var.master_username
  master_password         = var.master_password
  db_subnet_group_name    = aws_db_subnet_group.this.name
  backup_retention_period = 7
  preferred_backup_window = "08:00-09:00"
  storage_encrypted       = true
  deletion_protection     = false
  tags                    = local.tags
}

resource "aws_rds_cluster_instance" "writer" {
  identifier         = "${var.name}-writer-1"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = "db.r7g.large"
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version
  publicly_accessible = false
  tags               = local.tags
}

resource "aws_rds_cluster_instance" "reader" {
  count              = 2
  identifier         = "${var.name}-reader-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = "db.r7g.large"
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version
  publicly_accessible = false
  tags               = local.tags
}

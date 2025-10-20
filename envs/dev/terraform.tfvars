region             = "ap-northeast-2"
cluster_name       = "upx-eks-dev"
vpc_id             = "vpc-xxxxxxxx"
private_subnet_ids = ["subnet-aaaa","subnet-bbbb","subnet-cccc"]
public_subnet_ids  = ["subnet-dddd","subnet-eeee"]

primary_alb_arn    = ""
secondary_alb_arn  = ""

tags = { env = "dev", owner = "platform", project = "upx-exchange", domain = "dev.upx.exchange" }

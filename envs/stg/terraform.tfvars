region             = "ap-northeast-2"
cluster_name       = "upx-eks-stg"
vpc_id             = "vpc-xxxxxxxx"
private_subnet_ids = ["subnet-aaaa","subnet-bbbb","subnet-cccc"]
public_subnet_ids  = ["subnet-dddd","subnet-eeee"]

primary_alb_arn    = "arn:aws:elasticloadbalancing:ap-northeast-2:123456789012:loadbalancer/app/stg-alb/abcd1234"
secondary_alb_arn  = "arn:aws:elasticloadbalancing:ap-northeast-1:123456789012:loadbalancer/app/stg-dr-alb/efgh5678"

tags = { env = "stg", owner = "platform", project = "upx-exchange", domain = "stg.upx.exchange" }

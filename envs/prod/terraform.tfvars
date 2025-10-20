region             = "ap-northeast-2"
cluster_name       = "upx-eks-prod"
vpc_id             = "vpc-xxxxxxxx"
private_subnet_ids = ["subnet-aaaa", "subnet-bbbb", "subnet-cccc"]
public_subnet_ids  = ["subnet-dddd", "subnet-eeee"]

primary_alb_arn    = "arn:aws:elasticloadbalancing:ap-northeast-2:123456789012:loadbalancer/app/prod-alb/abcd1234"
secondary_alb_arn  = "arn:aws:elasticloadbalancing:ap-northeast-1:123456789012:loadbalancer/app/dr-alb/efgh5678"

tags = { env = "prod", owner = "platform", project = "upx-exchange", domain = "upx.exchange" }

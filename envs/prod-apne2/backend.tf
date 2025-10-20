terraform {
  backend "s3" {
    bucket = "upx-tfstate-sophielog"
    key    = "eks/prod-apne2/terraform.tfstate"
    region = "ap-northeast-2"
    encrypt = true
    dynamodb_table = "upx-tflock-sophielog"
  }
}

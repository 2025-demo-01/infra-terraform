terraform {
  backend "s3" {
    bucket         = "upx-tfstate-sophielog"
    key            = "eks/stg/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "upx-tflock-sophielog"
  }
}

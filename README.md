# infra-terraform

환경 별(VPC/EKS/MSK/Aurora/ClickHouse/Route53 등) IaC 모음.

너는. `envs/<env>/outputs.tf`에서 공개된 키만 참조합니다.

## 사용

```bash
make init ENV=dev
make plan ENV=dev
make apply ENV=dev
make outputs ENV=dev
```

---

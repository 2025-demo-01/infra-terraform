# infra-terraform  
#### - Infrastructure as Code for Exchange Platform

infra-terraform는 가상자산 거래소 환경에 특화된 **Production-Level IaC** 스택입니다.

AWS 상에서 Security · Resilience · Cost Control · Governance를 모두 코드로 구현합니다.

---

## 배포 흐름

1. Terraform 명령어(`terraform apply`)를 통해 **VPC → Endpoints → EKS + MSK + Aurora → Shared Services(KMS, SSM)** 등 전 리소스를 생성
2. 생성된 리소스는 `platform-argocd` Repository를 통해 **GitOps 방식으로 서비스(Application) 배포**에 사용됨
3. 각 서비스 레포(`svc-*`)는 IRSA/SSM/KMS 설정을 통해 이 인프라 리소스에 접근하며,
    
    **Observability Stack**으로부터 메트릭·로그를 수집
    
4. DR 리허설(`tests-and-dr` 레포) 및 보안 정책(`policy-as-code`)은 이 인프라 위에서 동작하며,
    
    **전체 플랫폼의 운영 가능성**을 검증
    
    ### Quick Start
    
    1. `envs/dev/backend.hcl`에 **Terraform state backend** 설정
    2. `terraform init` → `terraform plan` → `terraform apply` (dev 환경)
    3. `modules/`로 신규 리소스 확장 가능 (예: `modules/enclave`)
    4. `envs/stg`, `envs/prod`로 동일한 구조 반복, 변수 선언만 교체
    5. CI GitHub Actions(`tf-ci.yaml`)가 fmt → tflint → tfsec 검사를 자동으로 수행

---

## 주요 기능

- **표준화된 Terraform 모듈**: `modules/` 폴더 아래 VPC, EKS, MSK, Aurora, ClickHouse, KMS, Budget 등 구성
- **Multi-Stage 환경 분리**: `envs/dev`, `envs/stg`, `envs/prod` 구조로 환경 격리 및 반복 가능
- **보안 기본 값**: IMDSv2, Non-Root 컨테이너, Encryption at Rest, VPC Endpoints, SCP 기반 계정 제어
- **Cost & Governance**: AWS Budgets, Tagging Standards, Drift Detection, Policy Enforcement
- **DR/고가용성**: Multi-AZ, Aurora Global DB, Kafka Cross-Region, Route53 ARC 버튼 전환 포함

---

## **Why this matters**

- **IaC**: 모든 리소스는 선언형으로 코드화되고 버전관리 됩니다.
- **GitOps**: 서비스 배포는 Git 리포지토리에 선언된 상태로 자동 조정됩니다.
- **Modular Design**: 재사용 가능한 Terraform 모듈로 유지보수가 간편합니다.
- **Security-by-Default**: 퍼블릭 접근 차단, 암호화, 최소권한 등 보안이 기본입니다.
- **Resilience & DR**: 장애 시 복구 경로가 코드로 준비되어 있으며, 자동 리허설까지 포함됩니다.
- **Cost Transparency**: Budgets 및 Infracost 연동으로 비용 변화를 사전에 파악할 수 있습니다.

---

## 운영 기준 목표

| Metric | 목표 |
| --- | --- |
| Resource Drift | ZERO – `terraform apply` 시 변경 없음 |
| Deployment Time | dev → prod 전 환경 반복 15 분 이내 |
| Budget Alerts | dev ≤ USD 200/month, prod 알림 설정 |
| Restore Time (DR) | Route53 ARC 전환 5분 이하 |
| Security Violations | ZERO 허용, Kyverno/OPA로 실시간 차단 |

---

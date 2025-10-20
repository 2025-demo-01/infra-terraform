- Region: ap-northeast-2 (primary), ap-northeast-1 (DR)
- EKS: system MNG + Karpenter NodePool (low-latency, general)
- Data: MSK(SCRAM), Aurora(MySQL), ClickHouse Operator
- Edge: ALB + ExternalDNS (+ Cloudflare/WAF는 platform-argocd에서)
- Observability: Prometheus/Alertmanager, Grafana, Loki, Tempo
- DR: Route53 Failover + HealthCheck + DR Rehearsal

시퀀스배포
Dev → Stg(canary 검증) → Prod(Flagger 자동화)  
보안: cosign 서명 없는 Artifact는 정책으로 차단, SOPS/IRSA 사용

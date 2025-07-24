# AWS EKS Terraform Infrastructure

AWS Well-Architected Framework를 따르는 EKS 클러스터 인프라를 Terraform으로 구성합니다.

## 포함된 구성 요소

### 핵심 인프라
- **VPC**: 다중 AZ 구성, NAT Gateway, Internet Gateway
- **EKS Cluster**: Managed Kubernetes 클러스터
- **EKS Managed Node Groups**: Auto Scaling 지원
- **OIDC Provider**: ServiceAccount 기반 IAM 역할 연결

### 애드온 및 컨트롤러
- **AWS Load Balancer Controller**: ALB/NLB 자동 프로비저닝
- **EBS CSI Driver**: 영구 볼륨 지원
- **ExternalDNS**: Route53 DNS 레코드 자동 관리
- **EFS CSI Driver**: 공유 파일 시스템 지원 (선택사항)

## 사용 방법

### 1. 사전 요구사항
- Terraform >= 1.0
- AWS CLI 구성
- kubectl (선택사항)

### 2. 설정
```bash
# 변수 파일 복사 및 수정
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 파일을 환경에 맞게 수정
```

### 3. 배포
```bash
# 초기화
terraform init

# 계획 확인
terraform plan

# 배포
terraform apply
```

### 4. kubeconfig 설정
```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

## 주요 변수

| 변수명 | 설명 | 기본값 |
|--------|------|--------|
| `cluster_name` | EKS 클러스터 이름 | - |
| `cluster_version` | EKS 버전 | "1.28" |
| `region` | AWS 리전 | "ap-northeast-2" |
| `vpc_cidr` | VPC CIDR 블록 | "10.0.0.0/16" |
| `domain_filters` | ExternalDNS 도메인 필터 | ["example.com"] |
| `enable_efs` | EFS CSI 드라이버 활성화 | false |

## 출력값

- `cluster_endpoint`: EKS 클러스터 엔드포인트
- `cluster_name`: EKS 클러스터 이름
- `vpc_id`: VPC ID
- `lb_controller_sa_arn`: Load Balancer Controller IAM 역할 ARN
- `external_dns_sa_arn`: ExternalDNS IAM 역할 ARN

## AWS Well-Architected Framework 준수

### 운영 우수성
- 모듈화된 구조로 유지보수 용이
- 자동화된 DNS 관리
- 태그 기반 리소스 관리

### 보안
- IRSA(IAM Roles for Service Accounts) 활용
- 최소 권한 원칙 적용
- 프라이빗 서브넷에 워커 노드 배치

### 안정성
- 다중 AZ 구성
- Auto Scaling 지원
- Managed 서비스 활용

### 성능 효율성
- 적절한 인스턴스 타입 선택
- EBS/EFS 스토리지 옵션 제공

### 비용 최적화
- On-Demand/Spot 인스턴스 선택 가능
- 필요에 따른 리소스 확장/축소
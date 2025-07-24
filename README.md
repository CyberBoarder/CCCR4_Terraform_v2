# AWS EKS Terraform Infrastructure

AWS Well-Architected Framework를 따르는 모듈화된 EKS 클러스터 인프라를 Terraform으로 구성합니다.

## 🎨 아키텍처 다이어그램

<img width="1501" height="1181" alt="EKS Architecture Diagram" src="https://github.com/user-attachments/assets/a4bb8538-a140-442f-99ef-6b8f8eb5e931" />

## 📁 프로젝트 구조

```
eks-terraform-v2/
├── main.tf                    # 메인 구성 파일
├── variables.tf               # 변수 정의
├── outputs.tf                 # 출력값 정의
├── versions.tf                # Provider 버전 제약
├── terraform.tfvars.example   # 변수 예시 파일
├── README.md                  # 프로젝트 문서
├── architecture-diagram.drawio # 아키텍처 다이어그램
└── modules/                   # 모듈 디렉터리
    ├── vpc/                   # VPC 모듈
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── eks/                   # EKS 모듈
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── iam/                   # IAM 모듈
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── policies/          # IAM 정책 파일들
    │       ├── lb-controller-policy.json
    │       └── external-dns-policy.json
    └── addons/                # Kubernetes 애드온 모듈
        ├── main.tf
        └── variables.tf
```

## 🏗️ 아키텍처 구성 요소

### 핵심 인프라
- **VPC 모듈**: 다중 AZ 구성, NAT Gateway, Internet Gateway
- **EKS 모듈**: Managed Kubernetes 클러스터 및 Node Groups
- **IAM 모듈**: IRSA 기반 서비스 계정 역할 관리
- **Addons 모듈**: Kubernetes 애드온 및 컨트롤러

### 포함된 서비스
- **AWS Load Balancer Controller**: ALB/NLB 자동 프로비저닝
- **EBS CSI Driver**: 영구 볼륨 지원
- **ExternalDNS**: Route53 DNS 레코드 자동 관리
- **EFS CSI Driver**: 공유 파일 시스템 지원 (선택사항)

## 🚀 사용 방법

### 1. 사전 요구사항
- Terraform >= 1.0
- AWS CLI 구성 및 인증
- kubectl (선택사항)

### 2. 설정
```bash
# 저장소 클론
git clone <repository-url>
cd eks-terraform-v2

# 변수 파일 생성 및 수정
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 파일을 환경에 맞게 수정
```

### 3. 배포
```bash
# Terraform 초기화
terraform init

# 실행 계획 확인
terraform plan

# 인프라 배포
terraform apply
```

### 4. kubeconfig 설정
```bash
# EKS 클러스터 접근 설정
aws eks update-kubeconfig --region <region> --name <cluster-name>

# 클러스터 상태 확인
kubectl get nodes
```

## ⚙️ 주요 변수

| 변수명 | 설명 | 기본값 | 필수 |
|--------|------|--------|------|
| `cluster_name` | EKS 클러스터 이름 | - | ✅ |
| `cluster_version` | EKS 버전 | "1.28" | ❌ |
| `region` | AWS 리전 | "ap-northeast-2" | ❌ |
| `vpc_cidr` | VPC CIDR 블록 | "10.0.0.0/16" | ❌ |
| `azs` | 가용영역 목록 | ["ap-northeast-2a", "ap-northeast-2c"] | ❌ |
| `node_groups` | EKS 노드 그룹 설정 | t3.medium 기본 설정 | ❌ |
| `domain_filters` | ExternalDNS 도메인 필터 | ["example.com"] | ❌ |
| `enable_efs` | EFS CSI 드라이버 활성화 | false | ❌ |
| `tags` | 공통 태그 | Environment, Terraform | ❌ |

## 📤 출력값

### EKS 클러스터
- `cluster_endpoint`: EKS 클러스터 API 엔드포인트
- `cluster_name`: EKS 클러스터 이름
- `cluster_oidc_issuer_url`: OIDC 발급자 URL

### 네트워킹
- `vpc_id`: VPC ID
- `private_subnets`: 프라이빗 서브넷 ID 목록
- `public_subnets`: 퍼블릭 서브넷 ID 목록

### IAM 역할
- `lb_controller_role_arn`: Load Balancer Controller IAM 역할 ARN
- `external_dns_role_arn`: ExternalDNS IAM 역할 ARN
- `ebs_csi_driver_role_arn`: EBS CSI Driver IAM 역할 ARN

## 🏛️ AWS Well-Architected Framework 준수

### 운영 우수성 (Operational Excellence)
- ✅ 모듈화된 구조로 유지보수 용이성 확보
- ✅ 자동화된 DNS 및 로드 밸런서 관리
- ✅ 일관된 태그 기반 리소스 관리
- ✅ Infrastructure as Code 적용

### 보안 (Security)
- ✅ IRSA(IAM Roles for Service Accounts) 활용
- ✅ 최소 권한 원칙 적용된 IAM 정책
- ✅ 프라이빗 서브넷에 워커 노드 배치
- ✅ 네트워크 격리 및 보안 그룹 적용

### 안정성 (Reliability)
- ✅ 다중 가용영역(Multi-AZ) 구성
- ✅ Auto Scaling 지원
- ✅ AWS Managed 서비스 활용
- ✅ 고가용성 NAT Gateway 구성

### 성능 효율성 (Performance Efficiency)
- ✅ 적절한 인스턴스 타입 선택 옵션
- ✅ EBS/EFS 스토리지 최적화
- ✅ 로드 밸런서 자동 프로비저닝

### 비용 최적화 (Cost Optimization)
- ✅ On-Demand/Spot 인스턴스 선택 가능
- ✅ 필요에 따른 리소스 확장/축소
- ✅ 리소스 태깅을 통한 비용 추적

## 🔧 모듈 상세 정보

### VPC 모듈
- 다중 AZ에 걸친 퍼블릭/프라이빗 서브넷 생성
- NAT Gateway 및 Internet Gateway 구성
- EKS 클러스터를 위한 적절한 서브넷 태깅

### EKS 모듈
- Managed EKS 클러스터 생성
- EKS Managed Node Groups 구성
- EBS CSI Driver 애드온 설치

### IAM 모듈
- IRSA를 위한 OIDC Provider 설정
- 각 서비스별 최소 권한 IAM 역할 생성
- 정책 파일 분리로 관리 용이성 향상

### Addons 모듈
- Kubernetes Service Account 생성
- Helm을 통한 애드온 설치
- 설정 가능한 애드온 옵션 제공

## 🛠️ 유지보수 가이드

### 모듈 업데이트
각 모듈은 독립적으로 업데이트 가능하며, 변경 시 해당 모듈만 영향을 받습니다.

### 새로운 애드온 추가
`modules/addons/` 디렉터리에 새로운 Helm 릴리스를 추가하여 확장 가능합니다.

### 보안 정책 수정
`modules/iam/policies/` 디렉터리의 JSON 파일을 수정하여 IAM 정책을 업데이트할 수 있습니다.

## 📋 문제 해결

### 일반적인 문제
1. **OIDC Provider 오류**: EKS 클러스터가 완전히 생성된 후 IAM 역할이 생성되는지 확인
2. **Helm 설치 실패**: Kubernetes provider가 올바르게 구성되었는지 확인
3. **노드 그룹 생성 실패**: 서브넷 태깅이 올바른지 확인

### 로그 확인
```bash
# Terraform 디버그 로그 활성화
export TF_LOG=DEBUG
terraform apply
```

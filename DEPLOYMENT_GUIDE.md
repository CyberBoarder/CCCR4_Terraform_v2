# EKS Terraform 배포 가이드

이 문서는 EKS 클러스터를 Terraform으로 배포할 때 발생할 수 있는 문제와 해결 방법을 정리한 가이드입니다.

## 🚀 권장 배포 순서

### 1단계: 기본 인프라 배포
```bash
# Terraform 초기화
terraform init

# 기본 인프라만 배포 (순환 종속성 방지)
terraform apply -target=module.vpc -target=module.eks -target=module.iam
```

### 2단계: kubeconfig 설정
```bash
# EKS 클러스터 접근 설정
aws eks update-kubeconfig --region ap-northeast-2 --name test-eks-cluster

# 클러스터 연결 확인
kubectl get nodes
```

### 3단계: 애드온 배포
```bash
# 애드온 모듈 배포
terraform apply

# 배포 상태 확인
kubectl get pods -n kube-system | grep -E "(aws-load-balancer|external-dns|ebs-csi)"
```

## ⚠️ 일반적인 문제와 해결 방법

### 1. 순환 종속성 오류
**문제**: `Cycle: module.eks.module.eks.kubernetes_config_map_v1_data.aws_auth, data.aws_eks_cluster.cluster...`

**원인**: Kubernetes provider가 EKS 클러스터 정보에 의존하면서 동시에 EKS 모듈이 Kubernetes 리소스를 생성하려고 할 때 발생

**해결 방법**:
```bash
# 1. 기본 인프라만 먼저 배포
terraform apply -target=module.vpc -target=module.eks -target=module.iam

# 2. kubeconfig 설정
aws eks update-kubeconfig --region ap-northeast-2 --name test-eks-cluster

# 3. 전체 배포
terraform apply
```

### 2. Webhook 연결 실패
**문제**: `no endpoints available for service "aws-load-balancer-webhook-service"`

**원인**: AWS Load Balancer Controller의 webhook이 완전히 준비되기 전에 External DNS가 배포되려고 할 때 발생

**해결 방법**:
```bash
# 30초 대기 후 재시도
sleep 30
terraform apply
```

### 3. EBS CSI 정책 오류
**문제**: `Policy arn:aws:iam::aws:policy/service-role/Amazon_EBS_CSI_DriverPolicy does not exist`

**원인**: 잘못된 IAM 정책 ARN 사용

**해결 방법**: `modules/iam/main.tf`에서 올바른 정책 ARN 사용
```hcl
resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver.name
}
```

### 4. Kubernetes Provider 연결 실패
**문제**: `dial tcp 127.0.0.1:80: connect: connection refused`

**원인**: kubeconfig가 설정되지 않았거나 잘못된 설정

**해결 방법**:
```bash
# kubeconfig 재설정
aws eks update-kubeconfig --region ap-northeast-2 --name test-eks-cluster

# 연결 확인
kubectl cluster-info

# Terraform 재실행
terraform apply
```

## 🔍 배포 상태 확인 명령어

### EKS 클러스터 상태
```bash
# 클러스터 정보
aws eks describe-cluster --name test-eks-cluster --region ap-northeast-2

# 노드 상태
kubectl get nodes -o wide

# 노드 그룹 상태
aws eks describe-nodegroup --cluster-name test-eks-cluster --nodegroup-name main --region ap-northeast-2
```

### 애드온 상태 확인
```bash
# EKS 애드온 상태
aws eks describe-addon --cluster-name test-eks-cluster --addon-name aws-ebs-csi-driver --region ap-northeast-2

# Kubernetes 리소스 상태
kubectl get pods -n kube-system
kubectl get serviceaccounts -n kube-system | grep -E "(aws-load-balancer|external-dns)"
kubectl get deployments -n kube-system
```

### Helm 릴리스 상태
```bash
# Helm 릴리스 목록
helm list -n kube-system

# 특정 릴리스 상태
helm status aws-load-balancer-controller -n kube-system
helm status external-dns -n kube-system
```

## 🛠️ 문제 해결 도구

### Terraform 디버그
```bash
# 디버그 로그 활성화
export TF_LOG=DEBUG
terraform apply

# 특정 리소스만 재생성
terraform taint module.addons.helm_release.external_dns
terraform apply
```

### Kubernetes 이벤트 확인
```bash
# 최근 이벤트 확인
kubectl get events -n kube-system --sort-by='.lastTimestamp'

# 특정 파드 로그 확인
kubectl logs -n kube-system deployment/aws-load-balancer-controller
kubectl logs -n kube-system deployment/external-dns
```

### AWS 리소스 확인
```bash
# IAM 역할 확인
aws iam get-role --role-name test-eks-cluster-aws-load-balancer-controller
aws iam list-attached-role-policies --role-name test-eks-cluster-aws-load-balancer-controller

# OIDC Provider 확인
aws iam list-open-id-connect-providers
```

## 📋 배포 체크리스트

### 배포 전 확인사항
- [ ] AWS CLI 구성 및 인증 완료
- [ ] Terraform >= 1.0 설치
- [ ] kubectl 설치 (선택사항)
- [ ] terraform.tfvars 파일 설정 완료
- [ ] 필요한 AWS 권한 확인

### 배포 후 확인사항
- [ ] EKS 클러스터 상태: ACTIVE
- [ ] 노드 그룹 상태: ACTIVE
- [ ] 모든 노드 상태: Ready
- [ ] EBS CSI Driver 파드: Running
- [ ] AWS Load Balancer Controller 파드: Running
- [ ] External DNS 파드: Running
- [ ] IRSA 역할 정상 연결 확인

## 🔄 롤백 절차

문제 발생 시 롤백 방법:

```bash
# 1. 애드온만 제거
terraform destroy -target=module.addons

# 2. 전체 인프라 제거
terraform destroy

# 3. 특정 리소스만 제거
terraform destroy -target=module.addons.helm_release.external_dns
```

## 📞 추가 지원

더 자세한 정보나 문제 해결이 필요한 경우:
- [AWS EKS 문서](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider 문서](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Kubernetes 문서](https://kubernetes.io/docs/)
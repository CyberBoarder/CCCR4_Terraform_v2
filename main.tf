# Providers
provider "aws" {
  region = var.region
}

# Kubernetes and Helm providers
# 주의: EKS 클러스터가 생성된 후에 이 provider들이 작동합니다.
# 순환 종속성을 피하기 위해 기본 인프라 배포 후 애드온을 배포하는 것을 권장합니다.
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# VPC Module - 네트워크 인프라 생성
module "vpc" {
  source = "./modules/vpc"

  cluster_name    = var.cluster_name
  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  tags            = var.tags
}

# EKS Module - Kubernetes 클러스터 생성
module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = module.vpc.vpc_id
  private_subnets    = module.vpc.private_subnets
  node_groups        = var.node_groups
  tags               = var.tags
}

# IAM Module - IRSA 역할 생성
# 주의: EKS 클러스터의 OIDC provider가 생성된 후에 실행됩니다.
module "iam" {
  source = "./modules/iam"

  cluster_name       = var.cluster_name
  oidc_provider_arn  = module.eks.oidc_provider_arn
  oidc_issuer_url    = module.eks.cluster_oidc_issuer_url
  tags               = var.tags
}

# Addons Module
# 주의: 이 모듈은 EKS 클러스터와 IAM 역할이 완전히 생성된 후에 실행됩니다.
# kubeconfig 설정 후 배포하는 것을 권장합니다.
module "addons" {
  source = "./modules/addons"

  cluster_name            = var.cluster_name
  region                  = var.region
  vpc_id                  = module.vpc.vpc_id
  lb_controller_role_arn  = module.iam.lb_controller_role_arn
  external_dns_role_arn   = module.iam.external_dns_role_arn
  ebs_csi_role_arn        = module.iam.ebs_csi_driver_role_arn
  domain_filters          = var.domain_filters
  enable_efs              = var.enable_efs

  depends_on = [module.eks]
}
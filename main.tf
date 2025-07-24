# Providers
provider "aws" {
  region = var.region
}

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

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  cluster_name    = var.cluster_name
  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  tags            = var.tags
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  cluster_name       = var.cluster_name
  oidc_provider_arn  = module.eks.oidc_provider_arn
  oidc_issuer_url    = module.eks.cluster_oidc_issuer_url
  tags               = var.tags
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = module.vpc.vpc_id
  private_subnets    = module.vpc.private_subnets
  node_groups        = var.node_groups
  ebs_csi_role_arn   = module.iam.ebs_csi_driver_role_arn
  tags               = var.tags

  depends_on = [module.iam]
}

# Addons Module
module "addons" {
  source = "./modules/addons"

  cluster_name            = var.cluster_name
  region                  = var.region
  vpc_id                  = module.vpc.vpc_id
  lb_controller_role_arn  = module.iam.lb_controller_role_arn
  external_dns_role_arn   = module.iam.external_dns_role_arn
  domain_filters          = var.domain_filters
  enable_efs              = var.enable_efs

  depends_on = [module.eks]
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_irsa = true

  # Disable aws-auth ConfigMap management to avoid circular dependency
  manage_aws_auth_configmap = false

  eks_managed_node_groups = var.node_groups

  tags = var.tags
}
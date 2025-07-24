# EKS Cluster Outputs
output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "EKS cluster CA certificate"
  value       = module.eks.cluster_ca_certificate
  sensitive   = true
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_oidc_issuer_url" {
  description = "EKS cluster OIDC issuer URL"
  value       = module.eks.cluster_oidc_issuer_url
}

# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

# IAM Role Outputs
output "lb_controller_role_arn" {
  description = "AWS Load Balancer Controller IAM Role ARN"
  value       = module.iam.lb_controller_role_arn
}

output "external_dns_role_arn" {
  description = "ExternalDNS IAM Role ARN"
  value       = module.iam.external_dns_role_arn
}

output "ebs_csi_driver_role_arn" {
  description = "EBS CSI Driver IAM Role ARN"
  value       = module.iam.ebs_csi_driver_role_arn
}
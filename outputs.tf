output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "EKS cluster CA certificate"
  value       = module.eks.cluster_certificate_authority_data
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

output "lb_controller_sa_arn" {
  description = "AWS Load Balancer Controller Service Account ARN"
  value       = aws_iam_role.lb_controller.arn
}

output "external_dns_sa_arn" {
  description = "ExternalDNS Service Account ARN"
  value       = aws_iam_role.external_dns.arn
}

output "ebs_csi_driver_sa_arn" {
  description = "EBS CSI Driver Service Account ARN"
  value       = aws_iam_role.ebs_csi_driver.arn
}
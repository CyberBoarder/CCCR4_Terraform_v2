variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "lb_controller_role_arn" {
  description = "AWS Load Balancer Controller IAM role ARN"
  type        = string
}

variable "external_dns_role_arn" {
  description = "ExternalDNS IAM role ARN"
  type        = string
}

variable "domain_filters" {
  description = "Domain filters for ExternalDNS"
  type        = list(string)
}

variable "ebs_csi_role_arn" {
  description = "EBS CSI Driver IAM role ARN"
  type        = string
}

variable "enable_efs" {
  description = "Enable EFS CSI driver"
  type        = bool
}
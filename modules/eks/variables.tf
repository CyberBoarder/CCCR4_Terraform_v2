variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "node_groups" {
  description = "EKS managed node groups"
  type        = any
}

variable "ebs_csi_role_arn" {
  description = "EBS CSI Driver IAM role ARN"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}
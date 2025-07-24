output "ebs_csi_driver_role_arn" {
  description = "EBS CSI Driver IAM role ARN"
  value       = aws_iam_role.ebs_csi_driver.arn
}

output "lb_controller_role_arn" {
  description = "AWS Load Balancer Controller IAM role ARN"
  value       = aws_iam_role.lb_controller.arn
}

output "external_dns_role_arn" {
  description = "ExternalDNS IAM role ARN"
  value       = aws_iam_role.external_dns.arn
}
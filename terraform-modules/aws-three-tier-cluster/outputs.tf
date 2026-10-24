output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group IDs attached to the EKS control plane"
  value       = module.eks.cluster_security_group_id
}

output "cluster_name" {
  description = "The Kubernetes cluster name"
  value       = module.eks.cluster_name
}

output "vpc_id" {
  description = "The ID of the generated VPC"
  value       = module.vpc.vpc_id
}

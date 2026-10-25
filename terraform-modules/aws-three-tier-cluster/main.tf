# AWS EKS Cluster Configuration
module "eks" {
    source          = "terraform-aws-modules/eks/aws"
    version         = "~> 21.0"

    cluster_name    = "${var.environment}-three-tier-cluster"
    cluster_version = var.cluster_version
    cluster_endpoint_public_access = true

    # Security: Disable public access entirely in strict environments, 
  # or keep it enabled but locked down to your CIDR block
    vpc_id          = module.vpc.vpc_id
    subnets         = module.vpc.private_subnets

    # Enable KMS Encryption for Kubernetes Secrets natively
      create_kms_key = true
  cluster_encryption_config = {
    resources = ["secrets"]
  }
  # Enable EKS Access Entries (the modern way to handle cluster authentication instead of aws-auth ConfigMap)
  enable_cluster_creator_admin_permissions = true

  # Managed Worker Nodes Group running inside Private Subnets
  eks_managed_node_groups = {
    application_nodes = {
      min_size       = 2
      max_size       = 5
      desired_size   = 2
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      # Labels map resources inside Kubernetes schedules
        labels = {
            Tier = "Application"
      }

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 30
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true
          }
        }
      }
    }
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc"{
    source="terraform-aws-modules/vpc/aws"
    version= "~> 5.0"

name = "${var.environment}-three-tier-vpc"
cidr = var.vpc_cidr

 # Deploy across 3 Availability Zones for High Availability (HA)
azs = slice(data.aws_availability_zones.available.names, 0, 3)
public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
database_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

# NAT Gateway Strategy: One NAT Gateway per AZ in Production, or Single NAT in Dev to save costs
enable_nat_gateway = true
enable_single_nat_gateway = var.environment == "dev" ? true : false
one_nat_gateway_per_az = var.environment == "dev" ? true : false

# Isolate the database tier from the internet entirely
create_database_subnet_group = true
create_database_internet_gateway_route = false

enable_dns_hostnames = true
enable_dns_support = true

# Crucial tagging for AWS EKS Load Balancer Controller integration
public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.environment}-three-tier-cluster" = "shared"
  }

private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.environment}-three-tier-cluster" = "shared"
  }

tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


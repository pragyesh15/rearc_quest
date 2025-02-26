provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"  # Updated to latest stable version

  name = "quest-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}-a", "${var.region}-b"]  # Fixed AZ format
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.16.0"  # Updated version for compatibility

  cluster_name    = "quest-cluster"
  cluster_version = "1.21"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets  # EKS nodes should be in private subnets

  eks_managed_node_groups = {
    quest-node-group = {
      desired_size = 2
      max_size     = 3
      min_size     = 1

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }
  cluster_enabled_log_types = null
  enable_irsa = false
  cluster_encryption_config = []
  cloudwatch_log_group_retention_in_days = null
}

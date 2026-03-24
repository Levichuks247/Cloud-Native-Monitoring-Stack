# 1. Hardware Provider
provider "aws" {
  region = "eu-west-2"
}

# 2. Automatically find your Default VPC
data "aws_vpc" "default" {
  default = true
}

# 3. Find ALL Subnets in the Default VPC 
# This is more robust than filtering for 'public' which might not be tagged
data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 4. The EKS Cluster (The Monitoring Control Room)
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "monitoring-cluster"
  cluster_version = "1.31"

  # We use the VPC and Subnets found above
  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.all.ids

  # Crucial for Project 4: Ensures you have access to the cluster via Console/CLI
  enable_cluster_creator_admin_permissions = true

  # 5. Managed Node Group (The Workers)
  # We use t3.small because Prometheus & Grafana need the extra RAM
  eks_managed_node_groups = {
    monitoring_nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      instance_types = ["t3.small"]
      
      # This helps ensure nodes have enough IP addresses for the monitoring pods
      capacity_type = "ON_DEMAND"
    }
  }
}

# Output the Cluster Name so we can see it in the GitHub Logs
output "cluster_name" {
  value = module.eks.cluster_name
}
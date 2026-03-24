# 1. Automatically find your Default VPC 
data "aws_vpc" "default" {
  default = true
}

# 2. Find ALL Subnets in the Default VPC 
data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 3. The EKS Cluster (The Monitoring Control Room)
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "monitoring-cluster"
  cluster_version = "1.31"

  # Networking Setup
  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.all.ids

  # --- THE FIX FOR "ALREADY EXISTS" ERRORS ---
  # This tells Terraform NOT to try and create things that are already in AWS
  create_cloudwatch_log_group = false
  create_kms_key              = false
  # -------------------------------------------

  # Access Settings: Enables your local machine to connect via kubectl
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Crucial for Project 4: Grants your IAM user admin rights to the cluster
  enable_cluster_creator_admin_permissions = true

  # 4. Managed Node Group (The Workers)
  eks_managed_node_groups = {
    monitoring_nodes = {
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3.small"]
      
      # Ensures stability for our monitoring stack
      capacity_type = "ON_DEMAND"
    }
  }
}

# 5. Output the Cluster Name 
output "cluster_name" {
  value = module.eks.cluster_name
}
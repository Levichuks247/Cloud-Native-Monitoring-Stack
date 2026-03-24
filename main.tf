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

  # --- THE FIX FOR THE "UNSUPPORTED ATTRIBUTE" ERROR ---
  create_cloudwatch_log_group = false
  create_kms_key              = false
  
  # This tells the module: "Don't look for a provider_key_arn because we aren't using one"
  cluster_encryption_config = {} 
  attach_cluster_encryption_policy = false
  # ----------------------------------------------------

  # Access Settings
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Grants your IAM user admin rights to the cluster
  enable_cluster_creator_admin_permissions = true

  # 4. Managed Node Group (The Workers)
  eks_managed_node_groups = {
    monitoring_nodes = {
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }
  }
}

# 5. Output the Cluster Name 
output "cluster_name" {
  value = module.eks.cluster_name
}
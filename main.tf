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

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.all.ids

  # --- CRITICAL: PREVENT REPLACEMENT (MATCHING AWS ACTUALS) ---
  # This stops Terraform from trying to create a new IAM role
  create_iam_role = false
  iam_role_arn    = "arn:aws:iam::611538926967:role/monitoring-cluster-cluster-20260324092643765400000003"
  
  # Prevents replacement by matching the existing 'false' state
  bootstrap_self_managed_addons = false 

  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = "arn:aws:kms:eu-west-2:611538926967:key/4ee6adb0-ad16-456e-9274-4d5224d4cf3c"
  }

  attach_cluster_encryption_policy = true
  
  # Module-specific way to handle access config without triggering a recreate
  authentication_mode                         = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions    = true
  # ------------------------------------------------------------

  create_cloudwatch_log_group      = false
  create_kms_key                   = false
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

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
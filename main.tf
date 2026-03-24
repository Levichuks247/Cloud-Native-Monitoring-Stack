# 1. Automatically find your Default VPC 
# No need for manual IDs—this keeps your code portable!
data "aws_vpc" "default" {
  default = true
}

# 2. Find ALL Subnets in the Default VPC 
# This is more robust than filtering for 'public' tags, which often fail in default VPCs.
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

  # We use the VPC and Subnets discovered by the data sources above
  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.all.ids

  # Crucial for Project 4: Grants your IAM user admin rights to the cluster
  enable_cluster_creator_admin_permissions = true

  # 4. Managed Node Group (The Workers)
  # We use t3.small because Prometheus & Grafana need ~2GB of RAM to stay stable
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
# This confirms a successful build in your GitHub Action logs
output "cluster_name" {
  value = module.eks.cluster_name
}
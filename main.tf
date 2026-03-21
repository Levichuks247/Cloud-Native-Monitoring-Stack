# 1. Hardware Provider
provider "aws" {
  region = "eu-west-2"
}

# 2. Automatically find your Default VPC (No more manual 
IDs!)
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 3. The EKS Cluster (The Brain)
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "monitoring-cluster"
  cluster_version = "1.31"

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.public.ids

  # 4. Managed Node Group (The Workers)
  # We use t3.small because Grafana/Prometheus need ~2GB 
of RAM
  eks_managed_node_groups = {
    nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      instance_types = ["t3.small"]
    }
  }

  enable_cluster_creator_admin_permissions = true
}

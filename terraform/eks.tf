module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project}-${var.env}"
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  cluster_endpoint_public_access = true
  cluster_endpoint_public_access_cidrs = [
    "93.86.194.2/32"
  ]
  cluster_endpoint_private_access = true

  eks_managed_node_groups = {
    default = {
      desired_size = 2
      max_size     = 4
      min_size     = 1

      instance_types = ["t3.medium"]
    }
  }

  tags = {
    Project = var.project
    Env     = var.env
  }
  access_entries = {
    admin = {
      principal_arn = "arn:aws:iam::040443383169:user/terraform-admin"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    github_actions = {
      principal_arn = "arn:aws:iam::040443383169:user/cicd"

      policy_associations = {
        deploy = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}

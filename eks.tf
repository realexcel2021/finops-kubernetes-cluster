data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}




module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "finOps-cluster"
  cluster_version = "1.27"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true
   create_kms_key = true
  kms_key_owners = [ data.aws_caller_identity.current.arn ]

  iam_role_additional_policies = {
    EKSClusterAutoScalerPolicy      = aws_iam_policy.cluster_autoscaler_policy_for_eks.arn
    EKSNodegroupClusterIssuerPolicy = aws_iam_policy.eks_nodegroup_cluster_issuer_policy.arn
    EKSNodegroupExternalDNSPolicy   = aws_iam_policy.eks_nodegroup_exteral_dns_policy.arn
  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t2.small", "t2.medium"]
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 2
      desired_size = 2

      instance_types = ["t2.medium"]
      capacity_type  = "SPOT"
    }
  }

  tags = {
    Terraform = "true"
    Project   = "finOps"
  }
}
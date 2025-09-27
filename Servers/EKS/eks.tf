module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = local.name
  kubernetes_version = "1.33"

  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
  }

  # Optional
  endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    cluster_addon = {
      
    vpc_cni = {
      most_recent = true
    }

    kube_proxy = {
      most_recent = true
    }
    
    coredns = {
      most_recent = true
    }
    }

    sumeet-n_g = {
          # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_id_override       = "ami-0360c520857e3138f"
      instance_types = ["t3.medium"]
      attach_primary_security_group = true


      min_size     = 2
      max_size     = 3
      desired_size = 2

      capacity_type = "SPOT"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
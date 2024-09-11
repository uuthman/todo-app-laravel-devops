module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "20.24.0"
  cluster_name = var.cluster_name
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true


  tags = {
    cluster = "todo"
  }

  vpc_id = module.vpc.vpc_id

  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    instance_types         = ["t3.medium"]
    vpc_security_group_ids = [aws_security_group.worker_mgmt.id]
  }

  eks_managed_node_groups = {

    node_group = {
      min_size     = 2
      max_size     = 6
      desired_size = 2
    }
  }
}

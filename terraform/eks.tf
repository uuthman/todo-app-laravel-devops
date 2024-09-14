# module "eks" {
#   source = "terraform-aws-modules/eks/aws"
#   version = "20.24.0"
#   cluster_name = var.cluster_name
#   subnet_ids = module.vpc.private_subnets
#
#   enable_irsa = true
#
#
#   tags = {
#     cluster = "todo"
#   }
#
#   vpc_id = module.vpc.vpc_id
#
#   eks_managed_node_group_defaults = {
#     ami_type               = "AL2_x86_64"
#     instance_types         = ["t3.medium"]
#     vpc_security_group_ids = [aws_security_group.worker_mgmt.id]
#   }
#
#   eks_managed_node_groups = {
#     node_group = {
#       min_size     = 2
#       max_size     = 6
#       desired_size = 2
#     }
#   }
# }

resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = module.vpc.private_subnets
    security_group_ids = [aws_security_group.worker_mgmt.id]
    endpoint_private_access = true
    endpoint_public_access = true
  }

  access_config {
    authentication_mode = "CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = {
    Name = var.cluster_name
  }

  depends_on = [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy]
}

resource "aws_eks_node_group" "eks_node_group_ondemand" {
  cluster_name  = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster_name}-on-demand-nodes"
  node_role_arn = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids = module.vpc.private_subnets

  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }

  capacity_type = "ON_DEMAND"

  labels = {
    type = "ondemand"
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    "Name" = "${var.cluster_name}-ondemand-nodes"
  }


  depends_on = [aws_eks_cluster.eks]

}


# resource "aws_eks_node_group" "eks_node_group_spot" {
#   cluster_name  = aws_eks_cluster.eks.name
#   node_group_name = "${var.cluster_name}-spot-nodes"
#   node_role_arn = aws_iam_role.eks_nodegroup_role.arn
#   subnet_ids = module.vpc.private_subnets
#
#   instance_types = ["t3.medium","t3a.large", "t3a.xlarge"]
#
#   scaling_config {
#     desired_size = 2
#     max_size     = 4
#     min_size     = 2
#   }
#
#   capacity_type = "SPOT"
#
#   labels = {
#     type = "spot"
#   }
#
#   update_config {
#     max_unavailable = 1
#   }
#
#   disk_size = 50
#
#
#   depends_on = [aws_eks_cluster.eks]
#
# }
#
#
resource "aws_eks_addon" "eks_addons" {
  for_each      = { for idx, addon in var.addons : idx => addon }
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = each.value.name
  addon_version = each.value.version

  depends_on = [
    aws_eks_node_group.eks_node_group_ondemand,
#     aws_eks_node_group.eks_node_group_spot
  ]
}

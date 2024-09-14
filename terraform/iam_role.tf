resource "random_integer" "random_suffix" {
  min = 1000
  max = 9999
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-role-${random_integer.random_suffix.result}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role" "eks_nodegroup_role" {
  name = "${var.cluster_name}-nodegroup-role-${random_integer.random_suffix.result}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks-AmazonWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_policy" {
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# resource "aws_iam_policy" "ebs_csi_driver_policy" {
#   name        = "EBSCSIDriverPolicy"
#   description = "IAM policy for EBS CSI driver"
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = [
#           "ec2:CreateVolume",
#           "ec2:AttachVolume",
#           "ec2:DetachVolume",
#           "ec2:DeleteVolume",
#           "ec2:CreateSnapshot",
#           "ec2:DeleteSnapshot",
#           "ec2:DescribeVolumes",
#           "ec2:DescribeSnapshots",
#           "ec2:DescribeInstances",
#           "ec2:DescribeAvailabilityZones",
#           "ec2:DescribeVolumeStatus",
#           "ec2:DescribeVolumeAttribute",
#           "ec2:DescribeSnapshotAttribute",
#           "ec2:DescribeInstanceAttribute",
#           "ec2:DescribeInstanceCreditSpecifications",
#           "ec2:DescribeVolumeTypes",
#           "ec2:DescribeVpcAttribute",
#           "ec2:DescribeVpcEndpoints",
#           "ec2:DescribeVpcs",
#           "ec2:ModifyVolume",
#           "ec2:ModifyVolumeAttribute",
#           "ec2:ModifyInstanceAttribute"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }
#
#
# resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attachment" {
#   policy_arn = aws_iam_policy.ebs_csi_driver_policy.arn
#   role      = aws_iam_role.eks_nodegroup_role.name
# }


data "aws_iam_policy_document" "eks_oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:aws-test"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_oidc" {
  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role_policy.json
  name               = "${var.cluster_name}-oidc"
}


resource "aws_iam_policy" "eks_policy" {
  name = "${var.cluster_name}-policy"

  policy = jsonencode({
    Statement = [{
      Action = [
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation"
      ]
      Effect   = "Allow"
      Resource = "arn:aws:s3:::*"
    }]
    Version = "2012-10-17"
  })
}


resource "aws_iam_role_policy_attachment" "eks_attach" {
  role       = aws_iam_role.eks_oidc.name
  policy_arn = aws_iam_policy.eks_policy.arn
}


data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

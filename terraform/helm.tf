provider "helm" {
  kubernetes {
    host = aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args = ["eks", "get-token", "--cluster-name", aws_eks_cluster.eks.id]
      command     = "aws"
    }
  }

}

# resource "helm_release" "aws_ebs_csi_driver" {
#   name       = "aws-ebs-csi-driver"
#   repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
#   chart      = "aws-ebs-csi-driver"
#   namespace  = "kube-system"
#
#   set {
#     name  = "serviceAccount.name"
#     value = "ebs-csi-controller-sa"
#   }
#
#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.eks_ebs_csi_driver.arn
#   }
#
#   depends_on = [
#     aws_eks_addon.csi_driver
#   ]
#
# }

#aws loadbalancer controller
resource "helm_release" "aws-load-balancer-controller" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.4.4"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.eks.id
  }

  set {
    name  = "image.tag"
    value = "v2.4.7"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.aws_load_balancer_controller_irsa_role.iam_role_arn
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  depends_on = [
    aws_eks_cluster.eks,
    aws_eks_node_group.eks_node_group_ondemand,
#     aws_iam_role_policy_attachment.aws_load_balancer_controller_attach
  ]
}

#External DNS
locals {
  k8s = {
    type    = "eks"
    cluster = var.cluster_name
  }
}

data "aws_caller_identity" "eks" {}

data "aws_eks_cluster" "eks" {
  name = local.k8s.cluster
  depends_on = [aws_eks_cluster.eks]
}

data "aws_eks_cluster_auth" "aws_iam_authenticator" {
  name = data.aws_eks_cluster.eks.name
}

resource "helm_release" "external-dns" {
  name       = "external-dns"
  namespace  = "kube-system"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = "6.14.3"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_dns.arn
  }

  set {
    name  = "serviceAccount.name"
    value = "external-dns"
  }

  set {
    name  = "zoneType"
    value = "public"
  }

  set {
    name  = "policy"
    value = "sync"
  }

  set {
    name  = "domainFilters[0]"
    value = var.domain
  }

  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "txtOwnerId" #TXT record identifier
    value = "external-dns"
  }
}

resource "aws_iam_role" "external_dns" {
  name = "external-dns-dev"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.eks.account_id}:oidc-provider/${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:external-dns"
        }
      }
    }
  ]
}
  EOF
  tags = {
    Terraform = "true"
  }
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

resource "aws_iam_policy" "external_dns" {
  name        = "external-dns-dev"
  description = "Policy using OIDC to give the EKS external dns ServiceAccount permissions to update Route53"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
     "Effect": "Allow",
     "Action": [
       "route53:ChangeResourceRecordSets"
     ],
     "Resource": [
       "arn:aws:route53:::hostedzone/*"
     ]
   },
   {
     "Effect": "Allow",
     "Action": [
       "route53:ListHostedZones",
       "route53:ListResourceRecordSets"
     ],
     "Resource": [
       "*"
     ]
   }
  ]
}
EOF
}

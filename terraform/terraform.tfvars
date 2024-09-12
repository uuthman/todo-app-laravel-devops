vpc_cidr = "10.0.0.0/16"
private_subnet_cidrs = ["10.0.1.0/24","10.0.2.0/24"]
public_subnet_cidrs = ["10.0.4.0/24","10.0.5.0/24"]
cluster_name = "todo-cluster"
addons = [
  {
    name    = "vpc-cni",
    version = "v1.18.1-eksbuild.1"
  },
  {
    name    = "coredns"
    version = "v1.11.1-eksbuild.9"
  },
  {
    name    = "kube-proxy"
    version = "v1.29.3-eksbuild.2"
  },
  {
    name    = "aws-ebs-csi-driver"
    version = "v1.30.0-eksbuild.1"
  }
]

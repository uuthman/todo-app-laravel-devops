data "aws_availability_zones" "available" {}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = "todo-vpc"
  cidr = var.vpc_cidr

  azs = data.aws_availability_zones.available.names
  private_subnets = var.private_subnet_cidrs
  public_subnets = var.public_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support   = true



  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

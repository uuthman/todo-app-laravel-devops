variable "vpc_cidr" {
  description = "The CIDR for the vpc"
  type = string
}

variable "private_subnet_cidrs" {
  description = "The cidr for the private subnet"
  type = list(string)
}


variable "public_subnet_cidrs" {
  description = "The cidr for the public subnet"
  type = list(string)
}

variable "cluster_name" {
  description = "The name of the eks cluster"
  type = string
}

variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))
}

variable "domain" {
  description = "The domain url"
  type = string
}

variable "hosted_zone_id" {
  description = "the hosted zone id"
  type = string
}


terraform {
  required_version = "~>1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.81.0"
    }
  }
}

module "IPAM" {
  source = "./modules/aws-ipam"
}

data "aws_vpc_ipam_pool" "frankfurt" {
  filter {
    name   = "tag:Name"
    values = ["eu-central-1-pool"]
  }
  depends_on = [module.IPAM]
}

module "network_frankfurt" {
  source       = "./modules/aws-network"
  ipam_pool_id = data.aws_vpc_ipam_pool.frankfurt.ipam_pool_id
}
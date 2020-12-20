locals {
  public_cidr_block  = "${cidrsubnet("10.0.0.0/16", 1, 0)}"
}

module "eks_cluster" {
  source           = "./eks"
  cluster_name     = "${var.cluster_name}"
  cluster_version  = "1.18"
  base_cidr_block  = "${local.public_cidr_block}"
  vpc_id           = module.vpc.vpc_id
  availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  igw_id           = "${module.vpc.remessa_igw_id}"
  
  depends_on       = [module.vpc]
}

module "vpc" {
  source              = "./vpc"
  base_cidr_block     = "10.0.0.0/16"
  availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  cidr_block          = "${local.public_cidr_block}"
  
}
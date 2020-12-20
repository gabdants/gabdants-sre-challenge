resource "aws_vpc" "remessa" {
  cidr_block                       = var.base_cidr_block
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  enable_classiclink               = var.enable_classiclink
  enable_classiclink_dns_support   = var.enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "remessa-vpc-${terraform.workspace}"
  }
}

resource "aws_internet_gateway" "remessa" {
  vpc_id = join("", aws_vpc.remessa.*.id)

}
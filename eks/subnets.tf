locals {
  private_count       = length(var.availability_zones)
}

data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_subnet" "eks" {
  count = 3
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.base_cidr_block, 8, count.index + 3)
  vpc_id            = var.vpc_id
  map_public_ip_on_launch = true
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}-${terraform.workspace}" = "shared"
  }
}

resource "aws_network_acl" "private" {
  vpc_id     = var.vpc_id
  subnet_ids = aws_subnet.eks.*.id
  dynamic "egress" {
    for_each = var.private_network_acl_egress
    content {
      action          = lookup(egress.value, "action", null)
      cidr_block      = lookup(egress.value, "cidr_block", null)
      from_port       = lookup(egress.value, "from_port", null)
      icmp_code       = lookup(egress.value, "icmp_code", null)
      icmp_type       = lookup(egress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(egress.value, "ipv6_cidr_block", null)
      protocol        = lookup(egress.value, "protocol", null)
      rule_no         = lookup(egress.value, "rule_no", null)
      to_port         = lookup(egress.value, "to_port", null)
    }
  }
  dynamic "ingress" {
    for_each = var.private_network_acl_ingress
    content {
      action          = lookup(ingress.value, "action", null)
      cidr_block      = lookup(ingress.value, "cidr_block", null)
      from_port       = lookup(ingress.value, "from_port", null)
      icmp_code       = lookup(ingress.value, "icmp_code", null)
      icmp_type       = lookup(ingress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(ingress.value, "ipv6_cidr_block", null)
      protocol        = lookup(ingress.value, "protocol", null)
      rule_no         = lookup(ingress.value, "rule_no", null)
      to_port         = lookup(ingress.value, "to_port", null)
    }
  }
  depends_on = [aws_subnet.eks]
}

resource "aws_route_table" "private" {
  count  = local.private_count
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = {
      "Name" = "remessa-eks-private-route-table-${terraform.workspace}${var.delimiter}${element(var.availability_zones, count.index)}"
      "AZ"   = element(var.availability_zones, count.index)
      "Type" = "Private"
    }
}

resource "aws_route_table_association" "public" {
  count          = local.private_count
  subnet_id      = element(aws_subnet.eks.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
  depends_on = [
    aws_subnet.eks,
    aws_route_table.private,
  ]
}




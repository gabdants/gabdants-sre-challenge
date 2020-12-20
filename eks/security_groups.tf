resource "aws_security_group" "remessa_cluster" {
    name        = "eks-remessa-cluster-${terraform.workspace}"
    description = "EKS created security group applied to ENI that is attached to EKS Control Plane master nodes, as well as any managed workloads."
    vpc_id      = var.vpc_id

    ingress {
        from_port       = 30010
        to_port         = 30010
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
        description     = "Remessa App Access"
    }

    tags = {
        "Name"          = "security-group-eks-remessa-cluster-${terraform.workspace}"
    }
}

resource "aws_security_group_rule" "cluster_inbound" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.remessa_cluster.id
  source_security_group_id = aws_security_group.remessa_nodes.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_outbound" {
  description              = "Allow cluster API Server to communicate with the worker nodes"
  from_port                = 1024
  protocol                 = "tcp"
  security_group_id        = aws_security_group.remessa_cluster.id
  source_security_group_id = aws_security_group.remessa_nodes.id
  to_port                  = 65535
  type                     = "egress"
}


resource "aws_security_group" "remessa_nodes" {
    name        = "security-group-node-group-eks-${terraform.workspace}"
    description = "Security group for all nodes in the nodeGroup to allow SSH access"
    vpc_id      = var.vpc_id



    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    tags =  {
        "eks" = "remessa_cluster_node_group"
        "eks:nodegroup-name" = "remessa_cluster_node_group"
    }
}

resource "aws_security_group_rule" "nodes" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.remessa_nodes.id
  source_security_group_id = aws_security_group.remessa_nodes.id
  to_port                  = 65535
  type                     = "ingress"
}
resource "aws_security_group_rule" "nodes_inbound" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.remessa_nodes.id
  source_security_group_id = aws_security_group.remessa_cluster.id
  to_port                  = 65535
  type                     = "ingress"
}
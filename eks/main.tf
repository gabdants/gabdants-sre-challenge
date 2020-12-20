resource "aws_eks_node_group" "remessa_node_group_t3_large" {
    cluster_name    = aws_eks_cluster.remessa_cluster.name
    node_group_name = "remessa-node-group-t3-large-${terraform.workspace}"
    node_role_arn   = aws_iam_role.eks_cluster_node_admin_role.arn
    subnet_ids      = [for e in aws_subnet.eks.*.id : e]
    instance_types  = ["t3.large"]
    
    remote_access {
        source_security_group_ids   = [aws_security_group.remessa_nodes.id]
        ec2_ssh_key                 = "remessa"
    }

    scaling_config {
        desired_size = terraform.workspace == "prod" ? 8 : 1
        max_size     = 10
        min_size     = 1
    }

    tags = {
        "Name" = "EKS ${terraform.workspace} Node Group"
    }

}


resource "aws_eks_cluster" "remessa_cluster" {
  name                      = "${var.cluster_name}-${terraform.workspace}"
  role_arn                  = aws_iam_role.eks_cluster_admin_role.arn
  version                   = var.cluster_version
  enabled_cluster_log_types = ["api","audit","authenticator","controllerManager","scheduler"]

  vpc_config {
    endpoint_private_access   = true
    endpoint_public_access    = true
    subnet_ids                = [for e in aws_subnet.eks.*.id : e]
    security_group_ids        = [aws_security_group.remessa_cluster.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role.eks_cluster_admin_role,
    aws_iam_role.eks_cluster_node_admin_role,
    # aws_iam_role_policy_attachment.aws_eks_worker_node_policy,
    # aws_iam_role_policy_attachment.aws_eks_cni_policy,
    # aws_iam_role_policy_attachment.ec2_read_only,
    # aws_iam_role_policy_attachment.cluster_autoscaler,
  ]
}

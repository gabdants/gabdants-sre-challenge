output "vpc_id" {
  value       = join("", aws_vpc.remessa.*.id)
  description = "The ID of the VPC"
}

output "remessa_igw_id" {
  value       = aws_internet_gateway.remessa.id
  description = "The IGW ID of the Remessa VPC"
}



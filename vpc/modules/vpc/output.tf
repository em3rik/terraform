output "vpc_id" {
  description = "List of VPC IDs"
  value       = "${aws_vpc.vpc.id}"
}

#output "igw_id" {
#  description = "igw IDs"
#  value       = ["${aws_internet_gateway.vpc-igw.*.id}"]
#}
#
#output "vpc_default_route_table_id" {
#  description = "Default route VPC IDs"
#  value       = ["${aws_vpc.vpc.*.default_route_table_id}"]
#}


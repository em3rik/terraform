#output "vpc_ids" {
#  description = "List of VPC IDs"
#  value       = ["${module.vpc-1.vpc_id}", "${module.vpc-2.vpc_id}"]
#}
#
#output "peering_id" {
#  description = "List of VPC IDs"
#  value       = "${aws_vpc_peering_connection.vpc1_2.id}"
#}
#
#output "vpc_peering_id" {
#  description = "List of VPC peering ids"
#  value       = ["${module.peering-1.vpc_peering_id}"]
#}
#
#
#output "vpc_id" {
#  description = "List of VPC IDs"
#  value       = ["${module.vpc.id}"]
#}
#
#output "igw_id" {
#  description = "igw IDs"
#  value       = ["${module.vpc*.igw_id}"]
#}
#
#output "vpc_default_route_table_id" {
#  description = "Default route VPC IDs"
#  value       = ["${module.vpc*.vpc_default_route_table_id}"]
#}
#


### VPC ###

variable "vpc_cidr_block" {}
variable "vpc-name" {}

variable "public-subnets" {
  type = "map"
}

variable "private-subnets" {
  type = "map"
}

variable "availability-zones" {
  type = "list"
}

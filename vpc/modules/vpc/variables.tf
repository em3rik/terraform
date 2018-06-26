### VPC ###

variable "vpc_cidr_block" {}

variable "vpc-subnets" {
  type = "map"
}

variable "availability-zones" {
  type = "list"
}

variable "internet-gateway" {}

variable "vpc-name" {}

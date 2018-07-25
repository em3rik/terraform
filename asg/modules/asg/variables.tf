variable "key_name" {}
variable "vpc_name" {}
variable "public_key_path" {}
variable "instance_type" {}
variable "ec2_instance_name" {}
variable "public_ip" {}
variable "min_size" {}
variable "desired_capacity" {}
variable "max_size" {}
variable "env" {}

variable "subnet_names" {
  type = "list"
}

variable "lb_type" {}
variable "lb_name" {}

variable "instance_number" {
  default = 1
}

variable "elastic_ip" {
  default = "false"
}

variable "security_groups" {
  type = "list"
}

variable "key_name" {}
variable "vpc_name" {}
variable "subnet_name" {}
variable "public_key_path" {}
variable "instance_type" {}
variable "ec2_instance_name" {}
variable "public_ip" {}

variable "instance_number" {
  default = 1
}

variable "elastic_ip" {
  default = "false"
}

variable "security_groups" {
  type = "list"
}

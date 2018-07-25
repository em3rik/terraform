terraform {
  backend "s3" {
    bucket  = "intis-televend-terraform-tfstate"
    region  = "eu-west-2"
    key     = "ec2/terraform.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

module "openvpn_nlb" {
  source = "./modules/asg"

  lb_name          = "openvpn"
  lb_type          = "network"
  instance_type    = "t2.nano"
  min_size         = "1"
  max_size         = "1"
  desired_capacity = "1"
  env              = "development"
  key_name         = "terraform-ansible"
  public_key_path  = "./ssh_key/terraform-ansible.pub"
  vpc_name         = "transit"
  subnet_names     = ["transit-private1"]

  instance_type     = "t2.nano"
  ec2_instance_name = "ansible-test"
  public_ip         = "true"
  security_groups   = ["office-sg"]

  #  elastic_ip        = "true"
}

terraform {
  backend "s3" {
    bucket  = "terraform-tfstate"
    region  = "eu-west-2"
    key     = "ec2/terraform.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

#module "ec2" {
#  source = "./modules/ec2"
#
#  #  instance_number = 2
#  key_name        = "terraform-ansible"
#  public_key_path = "./ssh_key/terraform-ansible.pub"
#  vpc_name        = "transit"
#  subnet_name     = "transit-private1"
#
#  instance_type     = "t2.nano"
#  ec2_instance_name = "test"
#  public_ip         = "true"
#  security_groups   = ["office-sg"]
#
#  #  elastic_ip        = "true"
#}

module "ansible-test" {
  source = "./modules/ec2"

  #  instance_number = 2
  key_name        = "terraform-ansible"
  public_key_path = "./ssh_key/terraform-ansible.pub"
  vpc_name        = "transit"
  subnet_name     = "transit-private1"

  instance_type     = "t2.nano"
  ec2_instance_name = "ansible-test"
  public_ip         = "true"
  security_groups   = ["office-sg"]

  #  elastic_ip        = "true"
}

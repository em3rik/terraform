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

module "ec2-test" {
  source = "./modules/ec2"

  #  instance_number = 2
  key_name        = "test-1"
  public_key_path = "./ssh_key/terraform-ansible.pub"

  vpc_name    = "test-vpc"
  subnet_name = "public-test-1"

  instance_type     = "t2.nano"
  ec2_instance_name = "test"
  public_ip         = "true"
  security_groups   = ["transit-sg"]

  #  elastic_ip        = "true"
}

module "ec2-test2" {
  source = "./modules/ec2"

  #  instance_number = 2
  key_name        = "test-2"
  public_key_path = "./ssh_key/terraform-ansible.pub"

  vpc_name    = "test-vpc"
  subnet_name = "private-test-4"

  instance_type     = "t2.nano"
  ec2_instance_name = "test-2"
  public_ip         = "false"
  security_groups   = ["transit-sg"]

  #  elastic_ip        = "true"
}

module "ec2-vpc2" {
  source = "./modules/ec2"

  #  instance_number = 2
  key_name        = "test-3"
  public_key_path = "./ssh_key/terraform-ansible.pub"

  vpc_name    = "test-vpc2"
  subnet_name = "priv-test-3"

  instance_type     = "t2.nano"
  ec2_instance_name = "test-3"
  public_ip         = "false"
  security_groups   = ["transit-sg-2"]

  #  elastic_ip        = "true"
}

#module "ansible-test" {
#  source = "./modules/ec2"
#
#  #  instance_number = 2
#  key_name        = "terraform-ansible"
#  public_key_path = "./ssh_key/terraform-ansible.pub"
#  vpc_name        = "transit"
#  subnet_name     = "transit-private1"
#
#  instance_type     = "t2.nano"
#  ec2_instance_name = "ansible-test"
#  public_ip         = "true"
##  security_groups   = ["office-sg"]
#  security_groups   = [""]
#
#  #  elastic_ip        = "true"
#}
#
### imported ##
#module "test1" {
#  source = "./modules/ec2"
#
#  #  instance_number = 2
##  key_name        = "terraform-ansible"
##  public_key_path = "./ssh_key/terraform-ansible.pub"
##  vpc_name        = "entry"
##  subnet_name     = "transit-private1"
#
#  instance_type     = "t2.micro"
#  ec2_instance_name = "test1"
#  public_ip         = "true"
#  security_groups   = [""]
#
#  #  elastic_ip        = "true"
#}
#


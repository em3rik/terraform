terraform {
  backend "s3" {
    bucket  = "intis-televend-terraform-tfstate"
    region  = "eu-west-2"
    key     = "sg/terraform.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

module "test_security_group" {
  source   = "./modules/security_group"
  vpc_name = "test-vpc"
  sg_name  = "transit-sg"

  rules = {
    "10.11.12.13/32" = "22-25"
    "10.11.12.14/32" = "80"
  }

  protocol = "tcp"
}

module "test_security_group_2" {
  source   = "./modules/security_group"
  vpc_name = "test-vpc2"
  sg_name  = "transit-sg-2"

  rules = {
    "10.11.12.13/32" = "22-25"
    "10.11.12.14/32" = "80"
  }

  protocol = "tcp"
}

#module "office" {
#  source      = "./modules/security_group"
#  vpc_name    = "transit"
#  sg_name     = "office-sg"
#  protocol    = "-1"
#  cidr_blocks = ["0.0.0.0/0"]
#  ports       = ["0"]
#}


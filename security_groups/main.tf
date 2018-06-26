terraform {
  backend "s3" {
    bucket  = "intis-terraform-tfstate"
    region  = "eu-west-2"
    key     = "sg/terraform.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

#module "test_security_group" {
#  source      = "./modules/security_group"
#  vpc_name    = "transit"
#  sg_name     = "transit-sg"
#  cidr_blocks = ["10.11.12.13/32", "10.12.12.0/24"]
#  ports       = ["22", "80"]
#}

module "office" {
  source      = "./modules/security_group"
  vpc_name    = "transit"
  sg_name     = "office-sg"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  ports       = ["0"]
}

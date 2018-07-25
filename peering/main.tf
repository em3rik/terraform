### Remote terraform.tfstate configuration
terraform {
  backend "s3" {
    bucket  = "intis-televend-terraform-tfstate"
    region  = "eu-west-2"
    key     = "peering/terraform.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

### VPC peering between transit and common VPCs ###
module "test1-test2" {
  source = "./modules/peering"

  requester = "test-vpc"
  accepter  = "test-vpc2"
}

#### VPC peering between transit and common VPCs ###
#module "transit-common" {
#  source = "./modules/peering"
#
#  requester = "transit"
#  accepter  = "common"
#}
#
#### VPC peering between transit and connectivity VPCs ###
#module "transit-connectivity" {
#  source = "./modules/peering"
#
#  requester = "transit"
#  accepter  = "connectivity"
#}
#
#### VPC peering between prod-ec2 and prod-rds VPCs ###
#module "prod-ec2-prod-rds" {
#  source = "./modules/peering"
#
#  requester = "prod-ec2"
#  accepter  = "prod-rds"
#}


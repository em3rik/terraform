### Remote terraform.tfstate configuration
terraform {
  backend "s3" {
    bucket  = "intis-televend-terraform-tfstate"
    region  = "eu-west-2"
    key     = "route/terraform.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region  = "${var.aws_region}"
  profile = "intis"
  alias   = "intis"
}

module "test-routes" {
  source = "./modules/routes"

  vpc = "test-vpc2"

  public-subnet  = ""
  private-subnet = "priv-test-3"

  destination-cidr = "10.40.1.0/24"

  to-internet-gateway     = "false"
  to-nat-gateway          = "false"
  peering-connection-name = "test-vpc-test-vpc2"
  instance-name           = ""
}

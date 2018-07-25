### VPC additional routes ###
data "aws_route_table" "public-route-table" {
  count = "${var.public-subnet != "" ? 1 : 0}"

  tags {
    Name = "${var.public-subnet}"
  }
}

data "aws_route_table" "private-route-table" {
  count = "${var.private-subnet != "" ? 1 : 0}"

  tags {
    Name = "${var.private-subnet}"
  }
}

data "aws_vpc" "vpc" {
  tags {
    Name = "${var.vpc}"
  }
}

data "aws_internet_gateway" "vpc-igw" {
  filter {
    name   = "attachment.vpc-id"
    values = ["${data.aws_vpc.vpc.id}"]
  }
}

data "aws_subnet_ids" "private-subnet-id" {
  count  = "${var.private-subnet != "" ? 1 : 0}"
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags {
    Name = "${var.private-subnet}"
  }
}

data "aws_subnet_ids" "public-subnet-id" {
  count  = "${var.public-subnet != "" ? 1 : 0}"
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags {
    Name = "${var.public-subnet}"
  }
}

data "aws_nat_gateway" "nat-gateway" {
  count     = "${var.private-subnet != "" ? 1 : 0}"
  subnet_id = "${element(data.aws_subnet_ids.private-subnet-id.ids, count.index)}"
}

data "aws_caller_identity" "peer" {
  provider = "aws.intis"
}

data "aws_vpc_peering_connection" "peering" {
  count = "${var.peering-connection-name != "" ? 1 : 0}"

  peer_owner_id = "${data.aws_caller_identity.peer.account_id}"
  peer_owner_id = "${data.aws_caller_identity.peer.account_id}"
  status        = "active"

  tags {
    Name = "${var.peering-connection-name}"
  }
}

data "aws_instance" "ec2" {
  count = "${var.instance-name != "" ? 1 : 0}"

  instance_tags {
    Name = "${var.instance-name}"
  }
}

###------==#### Private ###==------###

#### Route to EC2 instance ###
resource "aws_route" "additional-public-routes-ec2-private" {
  count                  = "${(var.private-subnet != "" && var.destination-cidr != "" && var.to-internet-gateway == "false" && var.to-nat-gateway == "false" && var.peering-connection-name == "" && var.instance-name != "") ? 1 : 0}"
  route_table_id         = "${data.aws_route_table.private-route-table.id}"
  destination_cidr_block = "${var.destination-cidr}"
  instance_id            = "${data.aws_instance.ec2.id}"
}

#### Route to peering connection ###
resource "aws_route" "additional-public-routes-peering-private" {
  count                     = "${(var.private-subnet != "" && var.destination-cidr != "" && var.to-internet-gateway == "false" && var.to-nat-gateway == "false" && var.instance-name == "" && var.peering-connection-name != "") ? 1 : 0}"
  route_table_id            = "${data.aws_route_table.private-route-table.id}"
  destination_cidr_block    = "${var.destination-cidr}"
  vpc_peering_connection_id = "${data.aws_vpc_peering_connection.peering.id}"
}

#### Route to internet gateway ###
resource "aws_route" "additional-public-routes-nat" {
  count                  = "${(var.private-subnet != "" && var.destination-cidr != "" && var.to-internet-gateway == "false" && var.instance-name == "" && var.peering-connection-name == "" && var.to-nat-gateway == "true") ? 1 : 0}"
  route_table_id         = "${data.aws_route_table.private-route-table.id}"
  destination_cidr_block = "${var.destination-cidr}"
  gateway_id             = "${data.aws_nat_gateway.nat-gateway.id}"
}

####------==#### Public ####==------###

#### Route to EC2 instance ###
resource "aws_route" "additional-public-routes-ec2" {
  count                  = "${(var.public-subnet != "" && var.destination-cidr != "" && var.to-internet-gateway == "false" && var.to-nat-gateway == "false" && var.peering-connection-name == "" && var.instance-name != "") ? 1 : 0}"
  route_table_id         = "${data.aws_route_table.public-route-table.id}"
  destination_cidr_block = "${var.destination-cidr}"
  instance_id            = "${data.aws_instance.ec2.id}"
}

#### Route to peering connection ###
resource "aws_route" "additional-public-routes-peering" {
  count                     = "${(var.public-subnet != "" && var.destination-cidr != "" && var.to-internet-gateway == "false" && var.to-nat-gateway == "false" && var.instance-name == "" && var.peering-connection-name != "") ? 1 : 0}"
  route_table_id            = "${data.aws_route_table.public-route-table.id}"
  destination_cidr_block    = "${var.destination-cidr}"
  vpc_peering_connection_id = "${data.aws_vpc_peering_connection.peering.id}"
}

#### Route to internet gateway ###
resource "aws_route" "additional-public-routes-igw" {
  count                  = "${(var.public-subnet != "" && var.destination-cidr != "" && var.to-nat-gateway == "false" && var.instance-name == "" && var.peering-connection-name == "" && var.to-internet-gateway == "true") ? 1 : 0}"
  route_table_id         = "${data.aws_route_table.public-route-table.id}"
  destination_cidr_block = "${var.destination-cidr}"
  gateway_id             = "${data.aws_internet_gateway.vpc-igw.id}"
}

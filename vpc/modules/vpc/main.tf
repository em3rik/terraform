#### VPC ###

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "${var.vpc-name}"
  }
}

#### Internet gateway ###
resource "aws_internet_gateway" "vpc-igw" {
  count  = "${var.internet-gateway}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.vpc-name}"
  }
}

### Subnets ###
resource "aws_subnet" "vpc-subnet" {
  count      = "${length(keys(var.vpc-subnets))}"
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "${element(values(var.vpc-subnets), count.index)}"

  availability_zone = "${var.availability-zones[count.index%3]}"

  tags {
    Name = "${element(keys(var.vpc-subnets), count.index)}"
  }
}

### VPC routes ###
resource "aws_default_route_table" "routes-vpc" {
  count                  = "${var.internet-gateway == 0 ? 1 : 0 }"
  default_route_table_id = "${aws_vpc.vpc.default_route_table_id}"

  tags {
    Name = "${var.vpc-name}"
  }
}

resource "aws_route_table" "igw-route" {
  count  = "${var.internet-gateway}"
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc-igw.id}"
  }

  tags {
    Name = "${var.vpc-name}"
  }
}

#### Default route table associations ###
resource "aws_route_table_association" "vpc_subnet_association" {
  count          = "${var.internet-gateway == 0 ? length(keys(var.vpc-subnets)) : 0 }"
  subnet_id      = "${aws_subnet.vpc-subnet.*.id[count.index]}"
  route_table_id = "${aws_vpc.vpc.default_route_table_id}"
}

#### IGW route table associations ###
resource "aws_route_table_association" "igw_subnet_association" {
  count          = "${var.internet-gateway == 1 ? length(keys(var.vpc-subnets)) : 0}"
  subnet_id      = "${aws_subnet.vpc-subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.igw-route.id}"
}

#### Associate igw to main route ###
resource "aws_main_route_table_association" "default_route_subnet_association" {
  count          = "${var.internet-gateway}"
  vpc_id         = "${aws_vpc.vpc.id}"
  route_table_id = "${aws_route_table.igw-route.id}"
}

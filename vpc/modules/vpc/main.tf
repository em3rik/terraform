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
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.vpc-name}"
  }
}

### Elastic IP needed for NAT gateway ###
resource "aws_eip" "vpc-eip" {
  count      = "${length(keys(var.private-subnets))}"
  vpc        = true
  depends_on = ["aws_internet_gateway.vpc-igw"]
}

### NAT gateway###
resource "aws_nat_gateway" "nat-gw" {
  count         = "${length(keys(var.private-subnets))}"
  allocation_id = "${element(aws_eip.vpc-eip.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.private-subnet.*.id, count.index)}"

  depends_on = ["aws_internet_gateway.vpc-igw"]

  tags {
    Name = "${element(keys(var.private-subnets), count.index)}"
  }
}

### Public subnets ###
resource "aws_subnet" "public-subnet" {
  count      = "${length(keys(var.public-subnets))}"
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "${element(values(var.public-subnets), count.index)}"

  availability_zone = "${var.availability-zones[count.index%3]}"

  tags {
    Name = "${element(keys(var.public-subnets), count.index)}"
  }
}

### Private subnets ###
resource "aws_subnet" "private-subnet" {
  count      = "${length(keys(var.private-subnets))}"
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "${element(values(var.private-subnets), count.index)}"

  availability_zone = "${var.availability-zones[count.index%3]}"

  tags {
    Name = "${element(keys(var.private-subnets), count.index)}"
  }
}

### Adding name tag to default VPC route table ###
resource "aws_default_route_table" "routes-vpc" {
  default_route_table_id = "${aws_vpc.vpc.default_route_table_id}"

  tags {
    Name = "${var.vpc-name}"
  }
}

### Private route tables ###
resource "aws_route_table" "private-routes" {
  count  = "${length(keys(var.private-subnets))}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${element(keys(var.private-subnets), count.index)}"
  }
}

### Public route tables ###
resource "aws_route_table" "public-routes" {
  count  = "${length(keys(var.public-subnets))}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${element(keys(var.public-subnets), count.index)}"
  }
}

### Route private subnets to NAT gateways ###
resource "aws_route" "nat-route" {
  count                  = "${length(keys(var.private-subnets))}"
  route_table_id         = "${aws_route_table.private-routes.*.id[count.index]}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat-gw.*.id[count.index]}"
}

### Route public subnets to IGW ###
resource "aws_route" "igw-route" {
  count                  = "${length(keys(var.public-subnets))}"
  route_table_id         = "${aws_route_table.public-routes.*.id[count.index]}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.vpc-igw.id}"
}

#### Associate private subnets with private route tables ###
resource "aws_route_table_association" "private_subnet_association" {
  count          = "${length(keys(var.private-subnets))}"
  subnet_id      = "${aws_subnet.private-subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.private-routes.*.id[count.index]}"
}

#### Associate public subnets with public route tables ###
resource "aws_route_table_association" "public_subnet_association" {
  count          = "${length(keys(var.public-subnets))}"
  subnet_id      = "${aws_subnet.public-subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.public-routes.*.id[count.index]}"
}

# VPC Peering connections ###
data "aws_vpc" "requester" {
  tags {
    Name = "${var.requester}"
  }
}

data "aws_vpc" "accepter" {
  tags {
    Name = "${var.accepter}"
  }
}

resource "aws_vpc_peering_connection" "vpc_peering" {
  peer_vpc_id = "${data.aws_vpc.requester.id}"
  vpc_id      = "${data.aws_vpc.accepter.id}"
  auto_accept = true

  tags {
    Name = "${var.requester}-${var.accepter}"
  }
}

### Route tables ###
data "aws_route_table" "requester_route" {
  tags {
    Name = "${var.requester}"
  }
}

data "aws_route_table" "accepter_route" {
  tags {
    Name = "${var.accepter}"
  }
}

resource "aws_route" "requester_route" {
  route_table_id            = "${data.aws_route_table.requester_route.id}"
  destination_cidr_block    = "${data.aws_vpc.accepter.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peering.id}"
}

resource "aws_route" "accepter_route" {
  route_table_id            = "${data.aws_route_table.accepter_route.id}"
  destination_cidr_block    = "${data.aws_vpc.requester.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peering.id}"
}

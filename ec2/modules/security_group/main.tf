#### Security groups ###

data "aws_vpc" "selected" {
  tags {
    Name = "${var.vpc_name}"
  }
}

resource "aws_security_group" "security_group" {
  name   = "${var.sg_name}"
  vpc_id = "${data.aws_vpc.selected.id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_ssh_access" {
  type              = "ingress"
  security_group_id = "${aws_security_group.security_group.id}"
  from_port         = 0
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.cidr_blocks}"]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = "${aws_security_group.security_group.id}"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

data "aws_vpc" "selected" {
  tags {
    Name = "${var.vpc_name}"
  }
}

data "aws_subnet" "selected" {
  count  = "${length(var.subnet_names)}"
  vpc_id = "${data.aws_vpc.selected.id}"

  tags {
    Name = "${var.subnet_names[count.index]}"
  }
}

data "aws_security_group" "selected" {
  count = "${length(var.security_groups)}"

  filter {
    name   = "tag:Name"
    values = ["${var.security_groups[count.index]}"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

#resource "aws_launch_configuration" "selected" {
#  image_id        = "${data.aws_ami.ubuntu.id}"
#  instance_type   = "${var.instance_type}"
#  security_groups = ["${data.aws_security_group.selected.*.id}"]
#  key_name        = "${var.key_name}"
#
#  lifecycle {
#    create_before_destroy = true
#  }
#}

resource "aws_launch_template" "instance" {
  name                                 = "${var.lb_name}"
  image_id                             = "${data.aws_ami.ubuntu.id}"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "${var.instance_type}"
  key_name                             = "${var.key_name}"

  monitoring {
    enabled = true
  }

  #  network_interfaces {
  #    associate_public_ip_address = "${var.public_ip}"
  #    security_groups = ["${data.aws_security_group.selected.*.id}"]
  #  }


  #  placement {
  #    availability_zone = "us-west-2a"
  #  }

  vpc_security_group_ids = ["${data.aws_security_group.selected.*.id}"]
  tag_specifications {
    resource_type = "instance"

    tags {
      Name = "${var.lb_name}"
    }
  }
}

resource "aws_lb_target_group" "openvpn" {
  name     = "tf-example-lb-tg"
  port     = 943
  protocol = "TCP"
  vpc_id   = "${data.aws_vpc.selected.id}"

  stickiness {
    type    = "lb_cookie"
    enabled = false
  }
}

resource "aws_lb" "openvpn" {
  name               = "${var.lb_name}"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["${data.aws_subnet.selected.*.id}"]

  enable_deletion_protection = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "openvpn" {
  load_balancer_arn = "${aws_lb.openvpn.arn}"
  port              = "943"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.openvpn.arn}"
    type             = "forward"
  }
}

resource "aws_autoscaling_group" "selected" {
  name = "${var.lb_name}"

  #  launch_configuration = "${aws_launch_configuration.selected.id}"
  launch_template = {
    id = "${aws_launch_template.instance.id}"
  }

  #  availability_zones   = ["${data.aws_availability_zones.all.names}"]

  vpc_zone_identifier = ["${data.aws_subnet.selected.id}"]
  target_group_arns   = ["${aws_lb_target_group.openvpn.arn}"]
  health_check_type   = "ELB"
  min_size            = "${var.min_size}"
  max_size            = "${var.max_size}"
  desired_capacity    = "${var.desired_capacity}"
  min_elb_capacity    = "${var.min_size}"
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "Name"
    value               = "${var.lb_name}-${var.env}-asg"
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = "${var.env}"
    propagate_at_launch = true
  }
}

### SSH keys ###

resource "aws_key_pair" "ssh-key" {
  key_name = "${var.key_name}"

  public_key = "${file(var.public_key_path)}"
}

##### EC2 instance ###
#resource "aws_instance" "ec2-instance" {
#  count                       = "${var.instance_number}"
#  ami                         = "${data.aws_ami.ubuntu.id}"
#  instance_type               = "${var.instance_type}"
#  key_name                    = "${aws_key_pair.ssh-key.id}"
#  associate_public_ip_address = "${var.public_ip}"
#  subnet_id                   = "${data.aws_subnet.selected.id}"
#
#  vpc_security_group_ids = ["${data.aws_security_group.selected.*.id}"] ##??
#
#  tags {
#    Name = "${var.ec2_instance_name}"
#  }
#}
#
#### Elastic IP address ###
#
#resource "aws_eip_association" "eip_assoc" {
#  count         = "${var.elastic_ip == true ? var.instance_number : 0}"
#  instance_id   = "${aws_instance.ec2-instance.*.id[count.index]}"
#  allocation_id = "${aws_eip.ec2-elastic.*.id[count.index]}"
#
#  #  depends_on    = ["${aws_instance.ec2-instance.id}"]
#}
#
#resource "aws_eip" "ec2-elastic" {
#  count = "${var.elastic_ip == true ? var.instance_number : 0}"
#  vpc   = true
#}


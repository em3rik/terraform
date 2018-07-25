#### Basic EC2 resources ###
data "aws_vpc" "selected" {
  tags {
    Name = "${var.vpc_name}"
  }
}

data "aws_subnet" "selected" {
  vpc_id = "${data.aws_vpc.selected.id}"

  tags {
    Name = "${var.subnet_name}"
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

### SSH keys ###

resource "aws_key_pair" "ssh-key" {
  key_name = "${var.key_name}"

  public_key = "${file(var.public_key_path)}"
}

### EC2 instance ###
resource "aws_instance" "ec2-instance" {
  count                       = "${var.instance_number}"
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.ssh-key.id}"
  associate_public_ip_address = "${var.public_ip}"
  subnet_id                   = "${data.aws_subnet.selected.id}"

  vpc_security_group_ids = ["${data.aws_security_group.selected.*.id}"] ##??

  tags {
    Name = "${var.ec2_instance_name}"
  }
}

### Elastic IP address ###

resource "aws_eip_association" "eip_assoc" {
  count         = "${var.elastic_ip == true ? var.instance_number : 0}"
  instance_id   = "${aws_instance.ec2-instance.*.id[count.index]}"
  allocation_id = "${aws_eip.ec2-elastic.*.id[count.index]}"

  #  depends_on    = ["${aws_instance.ec2-instance.id}"]
}

resource "aws_eip" "ec2-elastic" {
  count = "${var.elastic_ip == true ? var.instance_number : 0}"
  vpc   = true
}

#output "public_ips" {
#  description = "EC2 public IPs"
#  value       = ["${aws_instance.ec2-instance.*.public_ip}"]
#}


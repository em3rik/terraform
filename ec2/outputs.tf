output "public_ips" {
  description = "EC2 public IPs"
  value       = ["${module.ansible-test.public_ips}"]
}

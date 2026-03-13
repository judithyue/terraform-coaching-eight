output "instance_public_ips" {
  description = "Public IP addresses of the EC2 instances"
  # We use a splat (*) to grab the IP from ALL instances created by count
  value = aws_instance.app_server[*].public_ip
}

output "ec2_sgp" {
  value = aws_security_group.ssh_access.id
}
# Security Group
resource "aws_security_group" "ssh_access" {
  name        = "${var.sgp_prefix}-ec2-sgp-ju"
  description = "Allow SSH for ec2 sgp"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.sgp_prefix}-sgp-ju" #fluffy-uat-sgp-ju
  })
}

# Ingress Rule (SSH)
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.ssh_access.id
  cidr_ipv4         = "0.0.0.0/0" # In real world, change to your IP!
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Allow ALL outbound traffic so we can download updates/CLI
resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.ssh_access.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # -1 means "all protocols"
}

# EC2 Instance
resource "aws_instance" "app_server" {
  count                       = var.ec2_count
  ami                         = data.aws_ami.ubuntu_jammy.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_ids[count.index % length(var.public_subnet_ids)]
  associate_public_ip_address = true
  #key_name                    = aws_key_pair.my_key.key_name
  iam_instance_profile = var.iam_instance_profile_name

  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y unzip
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install
              EOF

  tags = merge(var.tags, {
    # Use count.index so you get "app-0", "app-1", etc.
    Name = "${var.sgp_prefix}-webapp-${count.index}-ju"
  })
}

# key pair , but here we are using ec2 instance connect

/*
resource "aws_instance" "app_server" {
  # ... your other config ...

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y unzip
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install
              EOF
}
*/
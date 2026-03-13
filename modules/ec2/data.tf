# Find the latest Ubuntu 22.04 Jammy AMI
data "aws_ami" "ubuntu_jammy" {
  most_recent = true
  owners      = ["099720109477"] # Official Canonical Owner ID

  filter {
    name = "name"
    # The string you found in documentation!
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
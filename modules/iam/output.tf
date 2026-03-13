#The EC2 instance needs the name of the profile created here.
output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_instance_profile.name
}



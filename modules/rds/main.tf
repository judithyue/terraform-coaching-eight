# RDS Security Group
resource "aws_security_group" "rds_sgp" {
  name   = "${var.rds_prefix}-rds-sgp-ju"
  vpc_id = var.vpc_id

  ingress {
    from_port = 5432 # 3306 for MySQL
    to_port   = 5432
    protocol  = "tcp"
    # the key part: Reference the EC2 SG ID directly, allow inbound
    security_groups = [var.ec2_security_group_id]
  }

  tags = merge(var.tags, {
    Name = "${var.rds_prefix}-rds-sgp-ju"
  })

}

resource "aws_db_subnet_group" "main" {
  name       = "${var.rds_prefix}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids # 2 subnet is mandatory and have to be list [], which module vpc output.private_subnet_ids

  tags = merge(var.tags, {
  Name = "${var.rds_prefix}-rds-subnet-group" })
}

resource "aws_db_instance" "postgres" {
  identifier        = "${var.rds_prefix}-db-pgres-ju"
  allocated_storage = 20
  engine            = "postgres"
  engine_version    = "16.1"
  instance_class    = "db.t3.micro" # Free-tier eligible
  db_name           = "bookdb"
  username          = "adminuser"
  password          = random_password.db_master_password.result # ec2 get from Secrets Manager later, but for inital provisioning terraform need it to set the password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sgp.id]

  publicly_accessible = false # Keep it private!
  skip_final_snapshot = true

  # Ensures manual password changes in console don't trigger a Terraform revert
  lifecycle {
    ignore_changes = [password]
  }
}


/* --root/main.tf
module rds {
   tags = local.common_tags
   rds_prefix = local.prefix
   vpc_id = module.network.vpc_id
}

*/
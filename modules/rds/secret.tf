# 1. Generate the random password
resource "random_password" "db_master_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# 2. Create the Secret Container  <----- can be seprated as a module/secret/main in future
resource "aws_secretsmanager_secret" "db_secret" {
  name        = "${var.rds_prefix}-db-password-ju"
  description = "RDS Master Password for ${var.rds_prefix}"
  
  # Optional: Deletes the secret immediately upon 'terraform destroy' 
  # instead of waiting the default 30 days.
  recovery_window_in_days = 0 

    tags = merge(var.tags, {
    Name = "${var.rds_prefix}-secretmgr-ju"
  })
}

# 3. Store the password in the Container
resource "aws_secretsmanager_secret_version" "db_secret_val" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  # We store it as a JSON object so it's easy to read for humans and apps
  secret_string = jsonencode({
    username = "adminuser"
    password = random_password.db_master_password.result
    engine   = "postgres"
    host     = aws_db_instance.postgres.address
    port     = 5432
  })
}
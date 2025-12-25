resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.project}-${var.env}-db-password"
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({ password = random_password.db.result })
}

resource "random_password" "db" {
  length  = 16
  special = true
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.project}-${var.env}-db"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_db_instance" "postgres" {
  identifier = "${var.project}-${var.env}-db"

  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"

  allocated_storage = 20
  storage_encrypted = true

  db_name  = "realworld"
  username = "realworld"
  password = jsondecode(aws_secretsmanager_secret_version.db_password_version.secret_string)["password"]

  multi_az            = true
  backup_retention_period = 7
  backup_window           = "02:00-03:00"
  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = [module.vpc.default_security_group_id]

  skip_final_snapshot = true
}

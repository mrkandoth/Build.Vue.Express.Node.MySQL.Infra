variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_username" {
  description = "Username for the database"
  type        = string
}

variable "db_password" {
  description = "Password for the database"
  type        = string
}

variable "db_instance_class" {
  description = "Instance class for the database"
  type        = string
}

variable "db_identifier" {
  description = "Database identifier"
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage for the database (in GB)"
  type        = number
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "ID of the ECS service security group"
  type        = string
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "final_snapshot_identifier" {
  type    = string
  default = ""
}

resource "aws_security_group" "rds_security_group" {
  name        = "rds-security-group"
  description = "Security group for RDS instance"

  vpc_id = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "rds-subnet-group"
  description = "Subnet group for RDS"
  subnet_ids  = var.private_subnet_ids
}

resource "aws_db_instance" "rds_instance" {
  engine               = "mysql"
  instance_class       = var.db_instance_class
  allocated_storage    = var.db_allocated_storage
  identifier           = var.db_identifier
  username             = var.db_username
  password             = var.db_password
  db_name              = var.db_name
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot  = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier
  vpc_security_group_ids = [
    aws_security_group.rds_security_group.id,
  ]

  tags = {
    Name = "nbc-lab-rds"
  }
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.rds_instance.endpoint
}
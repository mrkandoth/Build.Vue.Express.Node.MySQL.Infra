module "vpc" {
  source                        = "../modules/vpc"
  vpc_cidr_block                = var.vpc_cidr_block
  public_subnet_a_cidr_block    = var.public_subnet_a_cidr_block
  public_subnet_b_cidr_block    = var.public_subnet_b_cidr_block
  private_subnet_a_cidr_block   = var.private_subnet_a_cidr_block
  private_subnet_b_cidr_block   = var.private_subnet_b_cidr_block
}

module "ecs" {
  source               = "../modules/ecs"
  vpc_id               = module.vpc.vpc_id
  security_group_id    = module.ecs.security_group_id
  public_subnet_ids    = [
    module.vpc.public_subnet_a_id,
    module.vpc.public_subnet_b_id
  ]
  private_subnet_ids   = [
    module.vpc.private_subnet_a_id,
    module.vpc.private_subnet_b_id
  ]
  task_definition_path = "./taskdefinition.json"
}

module "rds" {
  source                  = "../modules/rds"
  db_name                 = var.database_name
  db_username             = var.database_username
  db_password             = var.database_password
  db_identifier           = var.database_identifier
  ecs_security_group_id   = module.ecs.security_group_id
  db_instance_class       = "db.t2.micro"
  vpc_id                  = module.vpc.vpc_id
  db_allocated_storage    = 10
  skip_final_snapshot     = true
  final_snapshot_identifier = "nbc-lab-rds-backup"
  private_subnet_ids      = [
    module.vpc.private_subnet_a_id,
    module.vpc.private_subnet_b_id
  ]
}

output "loadbalancer_url" {
  value = module.ecs.nbc-lab-load_balancer
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.rds_endpoint
}

output "aws_ecs_cluster" {
  value = module.ecs.nbc-lab-ecs-cluster-name.name
}

output "aws_ecs_service" {
  value = module.ecs.nbc-lab-ecs-service-name.name
}
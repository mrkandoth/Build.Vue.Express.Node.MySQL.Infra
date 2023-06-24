module "vpc" {
  source                      = "../modules/vpc"
  vpc_cidr_block              = var.vpc_cidr_block
  public_subnet_a_cidr_block  = var.public_subnet_a_cidr_block
  public_subnet_b_cidr_block  = var.public_subnet_b_cidr_block
  private_subnet_cidr_block   = var.private_subnet_cidr_block
}

module "ecs" {
  source               = "../modules/ecs"
  vpc_id               = module.vpc.vpc_id
  security_group_id    = module.ecs.security_group_id
  public_subnet_ids    = [
    module.vpc.public_subnet_a_id,
    module.vpc.public_subnet_b_id
  ]
  private_subnet_ids   = [module.vpc.private_subnet_id]
  task_definition_path = "./taskdefinition.json"
}
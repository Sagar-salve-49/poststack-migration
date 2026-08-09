data "aws_caller_identity" "current" {}

module "networking" {
  source = "./modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

module "security" {
  source = "./modules/security"

  project_name           = var.project_name
  environment            = var.environment
  aws_region             = var.aws_region
  vpc_id                 = module.networking.vpc_id
  vpc_cidr               = var.vpc_cidr
  private_app_subnet_ids = module.networking.private_app_subnet_ids
  container_port         = var.container_port
}

module "alb" {
  source = "./modules/alb"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  container_port        = var.container_port
}

module "ecs" {
  source = "./modules/ecs"

  aws_region                  = var.aws_region
  project_name                = var.project_name
  environment                 = var.environment
  vpc_id                      = module.networking.vpc_id
  private_app_subnet_ids      = module.networking.private_app_subnet_ids
  app_security_group_id       = module.security.app_security_group_id
  ecs_task_execution_role_arn = module.security.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.security.ecs_task_role_arn
  alb_target_group_arn        = module.alb.target_group_arn
  container_port              = var.container_port
}

module "cicd" {
  source = "./modules/cicd"

  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region
  ecr_repository_arn = module.ecs.ecr_repository_arn
  ecr_repository_url = module.ecs.ecr_repository_url
  log_group_name     = "/aws/codebuild/${var.project_name}-${var.environment}-app"
}

module "cicd_pipeline" {
  source = "./modules/cicd-pipeline"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  github_connection_arn = "arn:aws:codeconnections:ap-south-1:459640517515:connection/f4ada60d-bb62-42b2-b692-9277ae81b45c"
  github_repository     = "Sagar-salve-49/poststack-migration"
  github_branch         = "master"

  codebuild_project_name = module.cicd.codebuild_project_name

  ecs_cluster_name = module.ecs.ecs_cluster_name
  ecs_service_name = module.ecs.ecs_service_name

  ecs_task_execution_role_arn = "arn:aws:iam::459640517515:role/poststack-migration-dev-ecs-task-execution"
  ecs_task_role_arn           = "arn:aws:iam::459640517515:role/poststack-migration-dev-ecs-task"
}

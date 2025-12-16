terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {
    bucket  = "dl-learners-ops-staging"
    key     = "terraform_state"
    region  = "us-west-2"
    profile = "digitallearn"
  }
}

provider "aws" {
  region  = var.region
  profile = "digitallearn"

  default_tags {
    tags = {
      Project     = "DigitalLearn Learners"
      Environment = var.environment_name
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret" "rails_master_key" {
  name = "digitallearn/rails_master_key"
}

data "aws_secretsmanager_secret" "docker_credentials" {
  name = "digitallearn/docker_credentials"
}

resource "aws_ecr_repository" "ecr_repo" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "Multiple"
  }
}

module "vpc" {
  source = "../modules/vpc"

  project_name         = var.project_name
  environment_name     = var.environment_name
  region               = var.region
  public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidr = ["10.0.10.0/24", "10.0.20.0/24"]
  availability_zones   = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

module "load_balancer" {
  source = "../modules/load_balancer"

  project_name              = var.project_name
  environment_name          = var.environment_name
  vpc_id                    = module.vpc.vpc_id
  public_subnet_ids         = module.vpc.public_subnet_ids
  default_security_group_id = module.vpc.default_security_group_id
  certificate_arn           = var.certificate_arn
}

module "bastian" {
  source = "../modules/bastian"

  project_name              = var.project_name
  environment_name          = var.environment_name
  vpc_id                    = module.vpc.vpc_id
  public_subnet_ids         = module.vpc.public_subnet_ids
  default_security_group_id = module.vpc.default_security_group_id
}

module "database" {
  source = "../modules/database"

  project_name        = var.project_name
  environment_name    = var.environment_name
  region              = var.region
  vpc_id              = module.vpc.vpc_id
  db_snapshot_name    = "learners-db-snapshot-staging"
  bastian_sg_id       = module.bastian.bastian_sg_id
  application_sg_id   = module.application.application_sg_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  database_name       = var.database_name
  instance_size       = "db.t3.micro"
  skip_final_snapshot = true
  monitoring_interval = 0
}

module "ecs_cluster" {
  source = "../modules/ecs_cluster"

  project_name                   = var.project_name
  environment_name               = var.environment_name
  region                         = var.region
  insights_enabled               = false
  rails_master_key_arn           = data.aws_secretsmanager_secret.rails_master_key.arn
  app_capacity_provider_name     = module.application.capacity_provider_name
  sidekiq_capacity_provider_name = module.sidekiq.capacity_provider_name
}


module "redis" {
  source = "../modules/redis"

  project_name              = var.project_name
  environment_name          = var.environment_name
  node_type                 = "cache.t3.small"
  cache_node_type           = "cache.t4g.micro"
  subnet_ids                = module.vpc.private_subnet_ids
  vpc_id                    = module.vpc.vpc_id

  redis_alarm_emails        = var.alarm_notification_emails
}

module "application" {
  source = "../modules/application"

  project_name                   = var.project_name
  vpc_id                         = module.vpc.vpc_id
  region                         = var.region
  environment_name               = var.environment_name
  ecs_cluster_id                 = module.ecs_cluster.cluster_id
  ecs_cluster_name               = module.ecs_cluster.cluster_name 
  default_security_group_id      = module.vpc.default_security_group_id
  db_access_security_group_id    = module.database.db_access_security_group_id
  db_host                        = module.database.database_host
  redis_access_security_group_id = module.redis.redis_access_security_group_id
  public_subnet_ids              = module.vpc.public_subnet_ids
  desired_instance_count         = 1
  min_task_count                 = 1
  max_task_count                 = 2
  instance_type                  = "t3.small"
  service_memory                 = 512
  service_cpu                    = 512
  lb_target_group_arn            = module.load_balancer.lb_target_group_arn
  ssh_key_name                   = "ec2_test_key"
  rails_master_key_arn           = data.aws_secretsmanager_secret.rails_master_key.arn
  image                          = "${aws_ecr_repository.ecr_repo.repository_url}:${var.environment_name}"
  s3_bucket_arns = [
    "arn:aws:s3:::dl-uploads-${var.environment_name}",
    "arn:aws:s3:::dl-stageapp-lessons-zipped"
  ]
  task_execution_role_arn = module.ecs_cluster.ecs_task_execution_role_arn
}

module "sidekiq" {
  source = "../modules/sidekiq"

  project_name                   = var.project_name
  environment_name               = var.environment_name
  region                         = var.region
  vpc_id                         = module.vpc.vpc_id
  ecr_repository_url             = split("/", aws_ecr_repository.ecr_repo.repository_url)[0] # Repository base url for authentication
  ecr_project_uri                = aws_ecr_repository.ecr_repo.repository_url # Repository url ex/ /digitallearn
  ecs_cluster_name               = module.ecs_cluster.cluster_name
  ecs_cluster_id                 = module.ecs_cluster.cluster_id
  private_subnet_ids             = module.vpc.private_subnet_ids
  image                          = "${aws_ecr_repository.ecr_repo.repository_url}:${var.environment_name}"
  log_retention_days             = 7
  instance_type                  = "t3.small"
  desired_instance_count         = 1
  min_task_count                 = 1
  max_task_count                 = 2
  task_cpu                       = 1600
  memory_reservation             = 1600

  db_access_security_group_id    = module.database.db_access_security_group_id
  redis_access_security_group_id = module.redis.redis_access_security_group_id
  
  redis_host                     = module.redis.redis_endpoint
  redis_port                     = 6379
  db_host                        = module.database.database_host
  rails_master_key_arn           = data.aws_secretsmanager_secret.rails_master_key.arn
  task_execution_role_arn        = module.ecs_cluster.ecs_task_execution_role_arn
}

module "pipeline" {
  source = "../modules/pipeline"

  project_name         = var.project_name
  environment_name     = var.environment_name
  region               = var.region
  ecs_cluster_name     = module.ecs_cluster.cluster_name
  app_service_name     = module.application.service_name
  sidekiq_service_name = module.sidekiq.service_name
  ecr_repository_url   = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"
  ecr_project_uri      = aws_ecr_repository.ecr_repo.repository_url
  github_owner         = "commercekitchen"
  github_repo          = "cpldl"
  branch               = "develop"
  dockerhub_secret_arn = data.aws_secretsmanager_secret.docker_credentials.arn
  rails_master_key_arn = data.aws_secretsmanager_secret.rails_master_key.arn
}

module "waf" {
  project_name           = var.project_name
  environment_name       = var.environment_name
  source                 = "../modules/waf"
  region                 = var.region
  web_acl_name           = "DLStagingWAFACL"
  alb_arn                = module.load_balancer.load_balancer_arn
  enable_shield          = false
  rate_limiter_threshold = 300
}
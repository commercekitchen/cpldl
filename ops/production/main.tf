terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket  = "dl-learners-ops-production"
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

resource "aws_ecr_repository" "ecr_repo" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
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
  certificate_arn           = "arn:aws:acm:us-west-2:917415714855:certificate/59029bf5-610c-4057-aff4-6fa500856917"
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

  project_name     = var.project_name
  environment_name = var.environment_name
  region           = var.region
  vpc_id           = module.vpc.vpc_id
  #db_snapshot_name    = "TODO"
  multi_az            = true
  bastian_sg_id       = module.bastian.bastian_sg_id
  application_sg_id   = module.application.application_sg_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  database_name       = var.database_name
  instance_size       = "db.t3.small"
  skip_final_snapshot = false
  enable_monitoring   = true
  monitoring_interval = 5
}

module "application" {
  source = "../modules/application"

  project_name                = var.project_name
  vpc_id                      = module.vpc.vpc_id
  region                      = var.region
  environment_name            = var.environment_name
  default_security_group_id   = module.vpc.default_security_group_id
  db_access_security_group_id = module.database.db_access_security_group_id
  db_host                     = module.database.database_host
  db_username                 = var.db_username
  db_password                 = var.db_password
  public_subnet_ids           = module.vpc.public_subnet_ids
  instance_type               = "t3.medium"
  desired_instance_count      = 1
  lb_target_group_arn         = module.load_balancer.lb_target_group_arn
  ssh_key_name                = "ec2_test_key"
  rails_master_key            = var.rails_master_key
  s3_bucket_arns = [
    "arn:aws:s3:::dl-learners-uploads-${var.environment_name}",
    "arn:aws:s3:::dl-prodapp-storylines-${var.environment_name}-zipped"
  ]
}

module "pipeline" {
  source = "../modules/pipeline"

  project_name       = var.project_name
  environment_name   = var.environment_name
  region             = var.region
  ecs_cluster_name   = module.application.cluster_name
  ecs_service_name   = module.application.service_name
  ecr_repository_url = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"
  ecr_project_uri    = aws_ecr_repository.ecr_repo.repository_url
  github_owner       = "CKDev"
  github_repo        = "digital-learn-training"
  branch             = "main"
  oauth_token        = var.github_oauth_token
  rails_master_key   = var.rails_master_key
  docker_username    = var.docker_username
  docker_password    = var.docker_password
}

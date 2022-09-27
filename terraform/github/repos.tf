terraform {
  backend "s3" {
    bucket  = "<TF_STATE_BUCKET>"
    key     = "terraform/github/tfstate.tf"
    region  = "<AWS_DEFAULT_REGION>"
    encrypt = true
  }
  required_providers {
    github = {
      source  = "integrations/github"
      version = "4.26.0"
    }
  }
}

module "gitops" {
  source = "./templates/repository"

  repo_name          = "gitops"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
  team_engineers     = github_team.engineers.id
  team_admins        = github_team.admins.id
}

resource "github_repository_webhook" "gitops_atlantis_webhook" {
    repository = module.gitops.repo_name
  
    name = module.gitops.repo_name
    configuration {
      url          = "https://atlantis.<AWS_HOSTED_ZONE_NAME>/events"
      content_type = "json"
      insecure_ssl = false
      secret       = var.atlantis_repo_webhook_secret
    }
  
    active = true
  
    events = ["pull_request_review", "push", "issue_comment", "pull_request"]
}
variable "atlantis_repo_webhook_secret" {
  type = string
  default = ""
}

module "metaphor" {
  source = "./templates/repository"

  repo_name          = "metaphor"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
  team_engineers     = github_team.engineers.id
  team_admins        = github_team.admins.id
}

module "metaphor_go" {
  source = "./templates/repository"

  repo_name          = "metaphor-go"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
  team_engineers     = github_team.engineers.id
  team_admins        = github_team.admins.id
}

module "metaphor_frontend" {
  source = "./templates/repository"

  repo_name          = "metaphor-frontend"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
  team_engineers     = github_team.engineers.id
  team_admins        = github_team.admins.id
}
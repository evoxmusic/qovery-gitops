terraform {
  required_providers {
    qovery = {
      source = "qovery/qovery"
    }
  }
}

provider "qovery" {
  token = var.qovery_access_token
}

resource "qovery_project" "my_project" {
  organization_id = var.qovery_organization_id
  name            = "My TF Project"
}

resource "qovery_environment" "production" {
  project_id = qovery_project.my_project.id
  name       = "production"
  mode       = "PRODUCTION"
  cluster_id = var.qovery_cluster_id
}

resource "qovery_database" "my_database" {
  environment_id = qovery_environment.production.id
  name           = "My DB"
  type           = "POSTGRESQL"
  version        = "16"
  mode           = "CONTAINER"
  storage        = 10
  accessibility  = "PRIVATE"
}

resource "qovery_application" "my_backend" {
  environment_id = qovery_environment.production.id
  name           = "My Backend"
  cpu            = 300
  memory         = 256
  git_repository = {
    url       = "https://github.com/evoxmusic/ShortMe-URL-Shortener.git"
    branch    = "main"
    root_path = "/"
  }
  build_mode      = "DOCKER"
  dockerfile_path = "Dockerfile"
  ports           = [
    {
      internal_port       = 5555
      external_port       = 443
      protocol            = "HTTP"
      publicly_accessible = true
      is_default          = true
    }
  ]
  healthchecks = {
    readiness_probe = {
      type = {
        http = {
          port = 5555
          scheme = "HTTP"
          path = "/"
        }
      }
      initial_delay_seconds = 30
      period_seconds        = 10
      timeout_seconds       = 10
      success_threshold     = 1
      failure_threshold     = 3
    }
    liveness_probe = {
      type = {
        http = {
          port = 5555
          scheme = "HTTP"
          path = "/"
        }
      }
      initial_delay_seconds = 30
      period_seconds        = 10
      timeout_seconds       = 10
      success_threshold     = 1
      failure_threshold     = 3
    }
  }
  environment_variables = [
    {
      key   = "DATABASE_HOST"
      value = qovery_database.my_database.internal_host
    },
    {
      key   = "DATABASE_PORT"
      value = qovery_database.my_database.port
    },
    {
      key   = "DATABASE_USERNAME"
      value = qovery_database.my_database.login
    },
    {
      key   = "DATABASE_NAME"
      value = "postgres"
    },
    {
      key   = "DEBUG_APP"
      value = "true"
    },
  ]
  secrets = [
    {
      key   = "DATABASE_PASSWORD"
      value = qovery_database.my_database.password
    }
  ]
}

resource "qovery_deployment" "my_deployment" {
  environment_id = qovery_environment.production.id
  desired_state  = "RUNNING"
  version        = "a0282bb4-f5bb-44ed-882d-e067f92d106e"

  depends_on = [
    qovery_application.my_backend,
    qovery_database.my_database,
    qovery_environment.production,
  ]
}

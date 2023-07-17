locals {
  default_resources = {
    requests = {
      cpu    = "100m"
      memory = "256Mi"
    }
    limits = {
      cpu    = "500m"
      memory = "512Mi"
    }
  }
  db_resources = {
    "cpu"     = "500m"
    "memory"  = "1Gi"
    "storage" = "50Gi"
    "backups" = "10Gi"
  }

  // The default schema is 'data'.  If you need access to public, or other schemas, enter them here.
  required_schemas = []

  // Populate this with the configuration for each of your applications.
  apps = {
    backend = {
      replicas  = var.environment == "prod" ? 3 : 1
      resources = local.default_resources
      env = {
        vars = {
          PG_HOST    = module.database.db_svc.host
          PG_PORT    = module.database.db_svc.port
          PG_DB_NAME = module.database.db_svc.name
        }
        secrets = {
          "PG_USER" = {
            name = module.database.db_user_secret.writer
            key  = "username"
          }
          "PG_PASSWORD" = {
            name = module.database.db_user_secret.writer
            key  = "password"
          }
        }
      }
      volume_mounts = {}
      volumes = {
        persistent = null
        configmaps = null
        secrets    = null
      }
      ports = {
        backend = 3000
      }
    }
    frontend = {
      replicas      = var.environment == "prod" ? 2 : 1
      resources     = local.default_resources
      volume_mounts = {}
      volumes = {
        persistent = null
        configmaps = null
        secrets    = null
      }
      ports = {
        frontend = 80
      }
      ingress = {
        host = "${local.url}"
        services = [
          {
            service = "frontend"
            path    = ""
            port    = 80
          },
          {
            service = "backend"
            path    = "api"
            port    = 3000
          }
        ]
      }
    }
  }
  frontend_env_vars = {
    USAGE_TRACKER_DOMAIN_ID = "${var.USAGE_TRACKER_DOMAIN_ID}"
  }
  cronjobs = {
    etl = {
      schedule        = "* */6 * * *"
      run_immediately = true
      args            = "etl:run"
    }
  }
}

// ##########################################################################
// Do not change anything below this line unless you know what you are doing.
// ##########################################################################
// The following is the actual terraform code that defines your environments.
// The settings above are for ease of customization, but if you need something more complex,
// You will likely need to modify the template below.  Only do this if you know what you're doing.

module "prepare_env" {
  source                    = "git@github.com:pfizer-digital-manufacuring/pgs-poi-deploy.git//terraform/prepare_env?ref=v1"
  project                   = var.project
  environment               = var.environment
  rancher_cluster_name      = var.rancher_cluster_name
  keep_namespace_on_destroy = false
}

module "database" {
  source      = "git@github.com:pfizer-digital-manufacuring/pgs-poi-deploy.git//terraform/database?ref=v1"
  namespace   = module.prepare_env.namespace
  project     = var.project
  environment = var.environment

  resources = local.db_resources
  replicas  = var.environment == "prod" ? 3 : 2
}

module "dns-data" {
  source    = "git@github.com:pfizer-digital-manufacuring/pgs-poi-deploy.git//terraform/dns?ref=v1"
  dnsserver = var.solidserver_dnsserver
  dnszone   = var.solidserver_zone
  name      = "${local.url}-data.pfizer.com"
  value     = module.database.db_hostname
  ttl       = 600
}

resource "kubernetes_config_map_v1" "frontend-config" {
  metadata {
    name      = "frontend-config"
    namespace = module.prepare_env.namespace
  }

  data = {
    "app-config.json" = jsonencode(local.frontend_env_vars)
  }
}

module "application" {
  source   = "git@github.com:pfizer-digital-manufacuring/pgs-poi-deploy.git//terraform/application?ref=v1"
  for_each = local.apps

  name        = each.key
  namespace   = module.prepare_env.namespace
  project     = var.project
  environment = var.environment
  replicas    = try(each.value.replicas, 1)

  containers = {
    (each.key) = {
      image     = "${local.image_prefix}/${each.key}"
      tag       = var.release_version
      args      = try(each.value.args, null)
      command   = try(each.value.command, null)
      ports     = try(each.value.ports, null)
      resources = try(each.value.resources, local.default_resources)
      volume_mounts = each.key == "frontend" ? merge(each.value.volume_mounts, {
        frontend-config = {
          path = "/usr/share/nginx/html/config"
        }
      }) : each.value.volume_mounts
      env = try(each.value.env, {})
    }
  }

  ingress = try(each.value.ingress, { enabled = false })
  volumes = each.key == "frontend" ? merge(each.value.volumes, {
    configmaps = {
      frontend-config = {
        name = kubernetes_config_map_v1.frontend-config.metadata[0].name
      }
    }
  }) : each.value.volumes
}

module "dns" {
  source    = "git@github.com:pfizer-digital-manufacuring/pgs-poi-deploy.git//terraform/dns?ref=v1"
  dnsserver = var.solidserver_dnsserver
  dnszone   = var.solidserver_zone
  name      = "${local.url}.pfizer.com"
  value     = var.ingress_domain_name
  ttl       = 600
}

module "cronjob" {
  source   = "git@github.com:pfizer-digital-manufacuring/pgs-poi-deploy.git//terraform/cronjob?ref=v1"
  for_each = local.cronjobs

  name        = each.key
  namespace   = module.prepare_env.namespace
  project     = var.project
  environment = var.environment

  containers = {
    (each.key) = {
      image         = "${local.image_prefix}/${each.key}"
      tag           = var.release_version
      args          = each.value.args
      command       = each.value.command
      resources     = coalesce(each.value.resources, local.default_resources)
      volume_mounts = each.value.volume_mounts
      env           = each.value.env
    }
  }

  volumes = each.value.volumes

  schedule           = each.value.schedule
  concurrency_policy = each.value.concurrency_policy
  starting_deadline  = each.value.starting_deadline
  deadline           = each.value.deadline
  backoff_limit      = each.value.backoff_limit
  ttl                = each.value.ttl
  failed_history     = each.value.failed_history
  successful_history = each.value.successful_history
  run_immediately    = each.value.run_immediately
}

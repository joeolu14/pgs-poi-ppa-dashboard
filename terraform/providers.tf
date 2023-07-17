terraform {
  backend "kubernetes" {
    load_config_file = true
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.7.1"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "~> 1.21.0"
    }
    solidserver = {
      source  = "EfficientIP-Labs/solidserver"
      version = "~> 1.1.15"
    }
  }
}

provider "rancher2" {
  api_url    = var.rancher2_hostname
  access_key = var.rancher2_access_key
  secret_key = var.rancher2_secret_key
  insecure   = true
}

provider "kubernetes" {
  config_context = var.kube_context
}

provider "solidserver" {
  username  = var.solidserver_username
  password  = var.solidserver_password
  host      = var.solidserver_hostname
  sslverify = "false"
}

data "rancher2_cluster" "pgs-poi" {
  name = var.rancher_cluster_name
}

data "rancher2_project" "app" {
  name       = var.project
  cluster_id = data.rancher2_cluster.pgs-poi.id
}

locals {
  url                = var.environment == "prod" ? var.url_prefix : "${var.url_prefix}-${var.environment}"
  project_normalized = replace(lower(var.project), "/[[:space:]]|[-]/", "")
  image_prefix       = coalesce(var.image_prefix, "artifactory.pfizer.com/mxs/${replace(lower(var.project), "/[[:space:]]/", "-")}")
}

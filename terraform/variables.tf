## Application Variables
variable "USAGE_TRACKER_DOMAIN_ID" {
  description = "The Usage Tracker ID for the environment being deployed"
  type        = string
  default     = ""
}

variable "environment" {
  description = "The name of the environment we are deploying into."
  type        = string
}

variable "project" {
  description = "The name of the Project -- This must match what was defined in pgs-poi-infrastructure."
  type        = string
}

variable "url_prefix" {
  description = "The short url (portion before .pfizer.com) for Production.  Other environments will be appended to the end of this."
  type        = string
}

variable "image_prefix" {
  description = "The image path within artifactory (or other registry) that prefixes the image name. (Such as: artifactory.pfizer.com/mxs/example_app ).  If not set, will default to the normalized project name."
  type        = string
  default     = ""
}

variable "release_version" {
  description = "The release version of the images to deploy."
  type        = string
}

## General Variables
#
variable "rancher_cluster_name" {
  description = "The name of the rancher cluster to operate within"
  type        = string
}

## Rancher variables
#
variable "rancher2_access_key" {
  description = "Access Key generated in Rancher for Authentication"
  type        = string
}
variable "rancher2_secret_key" {
  description = "Secret Key generated in Rancher for Authentication"
  type        = string
  sensitive   = true
}
variable "rancher2_hostname" {
  description = "API URL to manage Rancher from"
  type        = string
}

## Kubernetes variables
#
variable "kube_context" {
  description = "Kubernetes Context"
  type        = string
}

## Solidserver variables
##  user/pass credentials for DNS automation
#
variable "solidserver_username" {
  description = "Solid Server username for DNS automation. NProd service account"
  type        = string
}
variable "solidserver_password" {
  description = "Solid Server password for DNS automation. Should be passed via TF_VAR_solidserver_password environment variable"
  type        = string
  sensitive   = true
}
## Hostname
#
variable "solidserver_hostname" {
  description = "Solidserver hostname to connect to"
  type        = string
}
## dnsserver object name
#
variable "solidserver_dnsserver" {
  description = "Solidserver dnsserver object name"
  type        = string
}
## Solidserver zone
#
variable "solidserver_zone" {
  description = "Solidserver zone name"
  type        = string
}

## AWS subnets are supplied as a temporary workaround as a fix for a known issue in PDCS environment
## This variable should be removed together with related annotation under LoadBalancer resource
#
variable "pdcs-aws-subnets" {
  description = "List of AWS subnets EKS cluster is running in PDCS environment."
  type        = list(string)
}

variable "ingress_domain_name" {
  description = "Address of the kubernetes ingress for the cluster."
  type        = string
}

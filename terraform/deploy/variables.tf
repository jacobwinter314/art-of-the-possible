variable "aks_cluster_name" {
  type        = string
  description = "Name assigned to the AKS cluster to deploy to."
}

variable "aks_resource_group_name" {
  type        = string
  description = "Name assigned to the resource group that the AKS cluster was deployed to."
}

variable "acr_host_name" {
  type        = string
  description = "Host name of the ACR containing the Docker image."
}

variable "acr_image_name" {
  type        = string
  description = "Name corresponding to the exact image to pull from the ACR (without acr host name prefix)."
}

variable "acr_image_tag" {
  type        = string
  description = "Tag corresponding to the exact image to pull from the ACR."
}

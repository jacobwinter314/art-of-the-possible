variable "workload_name" {
  type        = string
  description = "Name of the workload that the resources are a part of."
}

variable "environment_name" {
  type        = string
  description = "Name of the environment that these resources are a part of."
}

variable "location" {
  type        = string
  description = "Name of the region that the resources will be deployed to."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group that any created resources will be under."
}

variable "admin_enabled" {
  type        = bool
  description = "Determine if admin access to the ACR for logging in is enabled."
  default =  true
}

variable "sku_name" {
  type        = string
  description = "Sku to use for the ACR."
  default =  "Basic"
}

variable "acr_allow_admin_access" {
  type        = bool
  description = "Determine if admin access to the ACR for logging in is enabled."
  default =  true
}

variable "acr_sku_name" {
  type        = string
  description = "Sku to use for the ACR."
  default =  "Basic"
}

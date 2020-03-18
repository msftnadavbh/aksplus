# Demo group object id
variable "enable_aad_rbac" {
  default = false
}

variable "appdev_object_id" {
  type    = string
  default = ""
}
variable "opssre_object_id" {
  type    = string
  default = ""
}
variable "admins_object_id" {
  type    = string
  default = ""
}

# Enable application gateway ingress controller
variable "enable_agic" {
  default = false
}

variable "subscription_id" {
  default = ""
}

variable "resource_group_name" {
  default = ""
}

variable "identity_id" {
  default = ""
}

variable "identity_client_id" {
  default = ""
}

variable "application_gateway_name" {
  default = ""
}

variable "aks_fqdn" {
  default = ""
}

# Enable external dns
variable "enable_dns" {
  default = false
}

# Enable GPU node pool
variable "enable_gpu" {
  default = false
}

# Enable Windows node pool
variable "enable_windows" {
  default = false
}
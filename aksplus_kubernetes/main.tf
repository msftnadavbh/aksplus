module "aad_rbac" {
  source           = "./aad_rbac"
  enabled = var.enable_aad_rbac
  appdev_object_id = var.appdev_object_id
  opssre_object_id = var.opssre_object_id
  admins_object_id = var.admins_object_id
}


module "agic" {
  source  = "./agic"
  enabled = var.enable_agic
  subscription_id = var.subscription_id
  resource_group_name = var.resource_group_name
  identity_id = var.identity_id
  identity_client_id = var.identity_client_id
  application_gateway_name = var.application_gateway_name
  aks_fqdn = var.aks_fqdn
}

module "dns" {
  source  = "./dns"
  enabled = var.enable_dns
}

module "gpu" {
  source  = "./gpu"
  enabled = var.enable_gpu
}

module "windows" {
  source  = "./windows"
  enabled = var.enable_windows
}
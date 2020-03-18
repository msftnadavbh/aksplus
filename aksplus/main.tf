provider "azurerm" {
  version = "~>2.0"
  features {}
}

provider "random" {
  version = "~> 2.2"
}

# Random ID
resource "random_id" "aksplus" {
  byte_length = 6
}

# Resource group for aksplus
resource "azurerm_resource_group" "aksplus" {
  name     = "${var.business_unit}-AKSPlus"
  location = var.location
}

module "akskey" {
  source = "./ssh_key"
  name   = "akskey"
}

module "akssp" {
  source = "./service_principal"
  name   = "AKSPlus-SP-${random_id.aksplus.dec}"
}

module "aksui" {
  source              = "./user_identity"
  name                = "AKSPlus-UI-${random_id.aksplus.dec}"
  resource_group_name = azurerm_resource_group.aksplus.name
  location            = var.location
  principal_id        = module.akssp.service_principal_id
}

module "acr" {
  source              = "./acr"
  enabled             = var.enable_acr
  name                = "${lower(var.business_unit)}acr${random_id.aksplus.dec}"
  location            = var.location
  resource_group_name = azurerm_resource_group.aksplus.name
}

module "log_analytics" {
  source              = "./log_analytics"
  name                = "${var.business_unit}-LAWS-${random_id.aksplus.dec}"
  location            = var.location
  resource_group_name = azurerm_resource_group.aksplus.name
  solution_plan_map   = {}
}

module "vnet" {
  source              = "./vnet"
  name                = "${var.business_unit}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.aksplus.name
  address_space       = "10.32.0.0/16"
  enable_virtual_node = (var.enable_virtual_node && ! var.enable_private_link)
}

module "jumpbox" {
  source              = "./jumpbox"
  enabled             = (var.enable_private_link || var.enable_jumpbox)
  suffix              = "0"
  location            = var.location
  resource_group_name = azurerm_resource_group.aksplus.name
  subnet_id           = module.vnet.jumpbox_subnet_id
  admin_username      = var.admin_username
  admin_public_key    = module.akskey.public_key_openssh
}

module "aks" {
  source = "./aks"

  resource_group_name = azurerm_resource_group.aksplus.name
  name                = "${var.business_unit}AKS"
  dns_prefix          = "${lower(var.business_unit)}aks"

  location           = var.location
  kubernetes_version = var.kubernetes_version
  log_analytics_id   = module.log_analytics.id
  subnet_id          = module.vnet.aks_subnet_id
  aci_subnet_name    = module.vnet.aci_subnet_name

  admin_username = var.admin_username
  ssh_key_data   = module.akskey.public_key_openssh
  admin_password = var.admin_password

  client_id     = module.akssp.application_id
  client_secret = module.akssp.service_principal_password

  network_plugin                  = var.network_plugin
  network_policy                  = var.network_policy
  enable_pod_security_policy      = var.enable_pod_security_policy
  enable_azure_policy             = var.enable_azure_policy
  enable_kube_dashboard           = var.enable_kube_dashboard
  enable_auto_scaling             = var.enable_auto_scaling
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges
  enable_private_link             = var.enable_private_link
  enable_gpu                      = var.enable_gpu
  enable_windows                  = var.enable_windows
  enable_virtual_node             = (var.enable_virtual_node && ! var.enable_private_link)
  enable_diagnostic               = var.enable_aks_diagnostic
  enable_aad_rbac                 = var.enable_aad_rbac

  vm_size    = var.vm_size
  node_count = var.node_count
  min_count  = var.min_count
  max_count  = var.max_count

  gpu_vm_size    = var.gpu_vm_size
  gpu_node_count = var.gpu_node_count
  gpu_min_count  = var.gpu_min_count
  gpu_max_count  = var.gpu_max_count

  windows_vm_size = var.windows_vm_size
  windows_node_count = var.windows_node_count
  windows_min_count  = var.windows_min_count
  windows_max_count  = var.windows_max_count  

  client_app_id     = var.client_app_id
  server_app_id     = var.server_app_id
  server_app_secret = var.server_app_secret
  tenant_id         = var.tenant_id
}

module "appgw" {
  source              = "./appgw"
  enabled             = var.enable_appgw
  enable_diagnostic   = var.enable_appgw_diagnostic
  log_analytics_id    = module.log_analytics.id
  name                = "${var.business_unit}AGW"
  resource_group_name = azurerm_resource_group.aksplus.name
  location            = var.location
  subnet_id           = module.vnet.appgw_subnet_id
  private_ip_address  = cidrhost(module.vnet.appgw_address_prefix, 16)
  capacity = {
    min = 1
    max = 2
  }
  //zones = ["1", "2", "3"]
}

module "dns" {
  source              = "./dns"
  enabled             = var.enable_dns
  resource_group_name = "${var.business_unit}-Shared"
  location            = var.location
  dns_domain          = var.dns_domain
}

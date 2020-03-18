# Create virtual network (VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.address_space]
}

# Create AKS subnet to be used by nodes and pods
resource "azurerm_subnet" "aks" {
  name                 = "AKSSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = cidrsubnet(var.address_space, 5, 4)
}

# ACI subnet, used by virutal kubelet
resource "azurerm_subnet" "aci" {
  count = var.enable_virtual_node ? 1 : 0
  name                 = "ACISubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = cidrsubnet(var.address_space, 8, 40)
  delegation {
    name = "acidelegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

/*
# Create gateway subnet to be used by gateway
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = cidrsubnet(var.address_space, 8, 0)
}
*/

# Create jumpbox subnet to be used by jumpbox VM
resource "azurerm_subnet" "appgw" {
  name                 = "AppGWSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = cidrsubnet(var.address_space, 8, 2)
}

# Create jumpbox subnet to be used by jumpbox VM
resource "azurerm_subnet" "jumpbox" {
  name                 = "JumpboxSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = cidrsubnet(var.address_space, 8, 3)
}

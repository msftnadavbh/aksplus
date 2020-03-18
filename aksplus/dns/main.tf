resource "azurerm_resource_group" "dns" {
  count = var.enabled ? 1 : 0
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_dns_zone" "dns" {
  count = var.enabled ? 1 : 0  
  name                = var.dns_domain
  resource_group_name = azurerm_resource_group.dns[0].name
}
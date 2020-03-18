output "aci_subnet_name" {
  value = var.enable_virtual_node ? azurerm_subnet.aci[0].name : null
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks.id
}

output "appgw_subnet_id" {
  value = azurerm_subnet.appgw.id
}

output "appgw_address_prefix" {
  value = azurerm_subnet.appgw.address_prefix
}

output "jumpbox_subnet_id" {
  value = azurerm_subnet.jumpbox.id
}

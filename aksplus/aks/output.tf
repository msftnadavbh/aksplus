/*
output "host" {
  value = local.enable_aad ? azurerm_kubernetes_cluster.aks.kube_admin_config.0.host : azurerm_kubernetes_cluster.aks.kube_config.0.host
}

output "username" {
  value = local.enable_aad ? azurerm_kubernetes_cluster.aks.kube_admin_config.0.username : azurerm_kubernetes_cluster.aks.kube_config.0.username
}

output "password" {
  value = local.enable_aad ? azurerm_kubernetes_cluster.aks.kube_admin_config.0.password : azurerm_kubernetes_cluster.aks.kube_config.0.password
}

output "client_certificate" {
  value = local.enable_aad ? azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_certificate : azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
}

output "client_key" {
  value = local.enable_aad ? azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_key : azurerm_kubernetes_cluster.aks.kube_config.0.client_key
}

output "cluster_ca_certificate" {
  value = local.enable_aad ? azurerm_kubernetes_cluster.aks.kube_admin_config.0.cluster_ca_certificate : azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate
}
*/
output "kube_config" {
  value  = azurerm_kubernetes_cluster.aks.kube_config_raw
}

output "kube_admin_config" {
  value  = local.enable_aad_rbac ? azurerm_kubernetes_cluster.aks.kube_admin_config_raw : azurerm_kubernetes_cluster.aks.kube_config_raw
}

output "id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "fqdn" {
  value = azurerm_kubernetes_cluster.aks.fqdn
}
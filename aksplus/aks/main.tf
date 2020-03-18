locals {
  enable_aad_rbac = (var.enable_aad_rbac) && (var.client_app_id != "") && (var.client_app_id != "") && (var.server_app_secret != "") && (var.tenant_id != "")
  logs            = ["kube-apiserver", "kube-audit", "kube-controller-manager", "kube-scheduler", "cluster-autoscaler"]
  metrics         = ["AllMetrics"]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  default_node_pool {
    name                = "default"
    enable_auto_scaling = var.enable_auto_scaling
    min_count           = var.enable_auto_scaling ? var.min_count : null
    max_count           = var.enable_auto_scaling ? var.max_count : null
    node_count          = var.node_count
    vm_size             = var.vm_size
    vnet_subnet_id      = var.subnet_id
    max_pods            = 110
  }
  dns_prefix = var.dns_prefix
  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }
  private_link_enabled            = var.enable_private_link
  api_server_authorized_ip_ranges = var.enable_private_link ? [] : var.api_server_authorized_ip_ranges
  enable_pod_security_policy      = var.enable_pod_security_policy
  kubernetes_version              = var.kubernetes_version
  linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data = var.ssh_key_data
    }
  }
  network_profile {
    network_plugin = var.network_plugin
    network_policy = (var.network_plugin == "kubenet") ? "calico" : var.network_policy
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = var.log_analytics_id
    }
    azure_policy {
      enabled = var.enable_azure_policy
    }
    kube_dashboard {
      enabled = var.enable_kube_dashboard
    }
    dynamic "aci_connector_linux" {
      for_each = var.enable_virtual_node ? list(1) : []
      content {
        enabled     = true
        subnet_name = var.aci_subnet_name
      }
    }
  }
  role_based_access_control {
    dynamic "azure_active_directory" {
      for_each = local.enable_aad_rbac ? list(1) : []
      content {
        client_app_id     = var.client_app_id
        server_app_id     = var.server_app_id
        server_app_secret = var.server_app_secret
        tenant_id         = var.tenant_id
      }
    }
    enabled = true
  }
  # Forcefully set windows profile to avoid AKS override it
  windows_profile {
    admin_username = var.admin_username
    admin_password = var.admin_password
  }
  /*
  tags = {
    Environment = "aksplus"
  }
  */
}

resource "azurerm_kubernetes_cluster_node_pool" "gpu" {
  count                 = var.enable_gpu ? 1 : 0
  name                  = "gpu"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.gpu_vm_size
  enable_auto_scaling   = var.enable_auto_scaling
  min_count             = var.enable_auto_scaling ? var.gpu_min_count : null
  max_count             = var.enable_auto_scaling ? var.gpu_max_count : null
  node_count            = var.gpu_node_count
  node_taints           = ["sku=gpu:NoSchedule"]
  vnet_subnet_id        = var.subnet_id
}

resource "azurerm_kubernetes_cluster_node_pool" "windows" {
  count                 = var.enable_windows ? 1 : 0
  name                  = "win"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.windows_vm_size
  enable_auto_scaling   = var.enable_auto_scaling
  min_count             = var.enable_auto_scaling ? var.windows_min_count : null
  max_count             = var.enable_auto_scaling ? var.windows_max_count : null
  node_count            = var.windows_node_count
  node_taints           = ["sku=windows:NoSchedule"]
  os_type               = "Windows"
  vnet_subnet_id        = var.subnet_id
}

resource "azurerm_monitor_diagnostic_setting" "diag" {
  count                      = var.enable_diagnostic ? 1 : 0
  name                       = "${azurerm_kubernetes_cluster.aks.name}-diag"
  target_resource_id         = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id = var.log_analytics_id

  dynamic "log" {
    for_each = local.logs
    content {
      category = log.value
      enabled  = true
      retention_policy {
        enabled = true
        days    = 30
      }
    }
  }
  dynamic "metric" {
    for_each = local.metrics
    content {
      category = metric.value
      enabled  = true
      retention_policy {
        enabled = true
        days    = 30
      }
    }
  }
}

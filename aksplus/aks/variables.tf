variable location {
  default = "southeastasia"
}

variable "resource_group_name" {}

variable "name" {}
variable "dns_prefix" {}

variable "kubernetes_version" {
  default = "1.15.7"
}

variable "log_analytics_id" {}

variable "subnet_id" {}
variable "aci_subnet_name" {}

variable "client_id" {}
variable "client_secret" {}

variable "admin_username" {
  default = "azadmin"
}

variable "ssh_key_data" {}

variable "admin_password" {
  default = "AzureP@ssw0rd"
}

# azure | kubenet
variable "network_plugin" {
  default = "azure"
}

# calico | azure
# https://docs.microsoft.com/en-us/azure/aks/use-network-policies
variable "network_policy" {
  default = "calico"
}

# Pod security policies
# https://docs.microsoft.com/en-us/azure/aks/use-pod-security-policies
variable "enable_pod_security_policy" {
  default = false
}

# Azure policy for aks
# https://docs.microsoft.com/en-us/azure/governance/policy/concepts/rego-for-aks
variable "enable_azure_policy" {
  default = true
}

# Enable kubernetes dashboard
variable "enable_kube_dashboard" {
  default = true
}

# Cluster autoscalar
# https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler
variable "enable_auto_scaling" {
  default = true
}

# Secure access to the API server
# https://docs.microsoft.com/en-us/azure/aks/api-server-authorized-ip-ranges
variable "api_server_authorized_ip_ranges" {
  default = []
}

# Enable private cluster
# https://docs.microsoft.com/en-us/azure/aks/private-clusters
variable "enable_private_link" {
  default = false
}

# Enable virtual kubelet
# https://docs.microsoft.com/en-us/azure/aks/concepts-scale#burst-to-azure-container-instances
variable "enable_virtual_node" {
  default = false
}

# Enable GPU node
variable "enable_gpu" {
  default = false
}

# Enable windows node
variable "enable_windows" {
  default = false
}

# Enable diagnostic log
variable "enable_diagnostic" {
  default = false
}

# Enable AAD RBACK
variable "enable_aad_rbac" {
  default = false
}

# Default node pool settings
variable "vm_size" {
  default = "Standard_D2s_v3"
}
variable "node_count" {
  default = 1
}
variable "min_count" {
  default = 1
}
variable "max_count" {
  default = 3
}

# GPU node pool settings
variable "gpu_vm_size" {
  default = "Standard_NC6s_v2"
}
variable "gpu_node_count" {
  default = 1
}
variable "gpu_min_count" {
  default = 1
}
variable "gpu_max_count" {
  default = 3
}

# Windows node pool settings
variable "windows_vm_size" {
  default = "Standard_D2s_v3"
}
variable "windows_node_count" {
  default = 1
}
variable "windows_min_count" {
  default = 1
}
variable "windows_max_count" {
  default = 3
}

# Enable aad with aks
# https://docs.microsoft.com/en-us/azure/aks/azure-ad-integration
variable "client_app_id" {
  default = ""
}
variable "server_app_id" {
  default = ""
}
variable "server_app_secret" {
  default = ""
}
variable "tenant_id" {
  default = ""
}
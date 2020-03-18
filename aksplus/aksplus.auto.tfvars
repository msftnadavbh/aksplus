business_unit      = "Contoso"
location           = "eastasia"
kubernetes_version = "1.15.7"
admin_username     = "azadmin"
admin_password     = "AzureP@ssw0rd"

network_plugin             = "azure"
network_policy             = "calico"
enable_pod_security_policy = false
enable_azure_policy        = true
enable_kube_dashboard      = true
enable_auto_scaling        = true
#api_server_authorized_ip_ranges = []
#enable_private_link             = true
#enable_gpu             = true
enable_windows = true
#enable_virtual_node             = true

#enable_aad_rbac         = true
#enable_aks_diagnostic   = true
#enable_appgw            = true
#enable_appgw_diagnostic = true
#enable_acr              = true
#enable_jumpbox          = true
#enable_dns = true
dns_domain = "k8s.azcloud.top"

vm_size    = "Standard_D2s_v3"
node_count = 1
min_count  = 1
max_count  = 3

gpu_vm_size    = "Standard_NC6s_v2"
gpu_node_count = 1
gpu_min_count  = 1
gpu_max_count  = 3

windows_vm_size    = "Standard_D2s_v3"
windows_node_count = 1
windows_min_count  = 1
windows_max_count  = 3

# Enable AAD rbac
client_app_id     = "deabb2d2-ac74-42a6-8fa5-df230056b7c8"
server_app_id     = "a67f0918-8859-4eef-8d03-bae39ef5782c"
server_app_secret = "5lL57nXstL?DznKEnO/HrRwcr4X=LnB]"
tenant_id         = "fb2df0b9-9e24-4485-b183-ab863f8c9856"

appdev_object_id = "10b939cf-9c20-4497-ab94-eeb5dbef03b4"
opssre_object_id = "0a4a9533-26ab-4aca-9412-c8e7873d2ec5"
admins_object_id = "08dd83aa-1fa7-4235-b721-190d9b3c15f5"

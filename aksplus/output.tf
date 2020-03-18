# Genereate kube config files and terraform vars files used in aksplus_kubernetes
locals {
  enable_aad_rbac = (var.enable_aad_rbac) && (var.client_app_id != "") && (var.client_app_id != "") && (var.server_app_secret != "") && (var.tenant_id != "")
}

provider "local" {
  version = "~> 1.4"
}

# Kubernetes config files
resource "local_file" "kube_config" {
  content  = module.aks.kube_config
  filename = pathexpand("~/.kube/config")
}

resource "local_file" "kube_admin_config" {
  content  = module.aks.kube_admin_config
  filename = pathexpand("~/.kube/admin_config")
}

output "kube_config" {
  value = pathexpand("~/.kube/config")
}

output "kube_admin_config" {
  value = pathexpand("~/.kube/admin_config")
}

# AKS Azure active directory role based access control
resource "local_file" "aad_rbac" {
  content  = <<EOF
enable_aad_rbac = ${local.enable_aad_rbac ? true : false}
appdev_object_id = "${local.enable_aad_rbac ? var.appdev_object_id :""}"
opssre_object_id = "${local.enable_aad_rbac ? var.opssre_object_id :""}"
admins_object_id = "${local.enable_aad_rbac ? var.admins_object_id :""}"
EOF
  filename = pathexpand("../aksplus_kubernetes/aad_rbac.auto.tfvars")  
}

# Application gateway ingress controller
data "azurerm_subscription" "this" {
}

resource "local_file" "agic" {
  content  = <<EOF
enable_agic = ${var.enable_appgw ? true : false}
subscription_id = "${data.azurerm_subscription.this.subscription_id}"
resource_group_name = "${azurerm_resource_group.aksplus.name}"
identity_id = "${module.aksui.identity_id}"
identity_client_id = "${module.aksui.identity_client_id}"
application_gateway_name = "${var.business_unit}AGW"
aks_fqdn = "${module.aks.fqdn}"
EOF
  filename = pathexpand("../aksplus_kubernetes/agic.auto.tfvars")
}

# External DNS
resource "local_file" "dns" {
  content  = <<EOF
enable_dns = ${var.enable_dns ? true : false}
EOF
  filename = pathexpand("../aksplus_kubernetes/dns.auto.tfvars")
}

resource "local_file" "dns_yaml" {
  content  = <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-dns
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: external-dns
rules:
- apiGroups: [""]
  resources: ["services","endpoints","pods"]
  verbs: ["get","watch","list"]
- apiGroups: ["extensions"] 
  resources: ["ingresses"] 
  verbs: ["get","watch","list"]
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["list"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: external-dns-viewer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: external-dns
subjects:
- kind: ServiceAccount
  name: external-dns
  namespace: external-dns
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns
spec:
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: external-dns
  template:
    metadata:
      labels:
        app: external-dns
    spec:
      serviceAccountName: external-dns
      containers:
      - name: external-dns
        image: registry.opensource.zalan.do/teapot/external-dns:latest
        args:
        - --source=service
        - --source=ingress
        - --domain-filter=${var.dns_domain}
        - --provider=azure
        - --azure-resource-group=${var.business_unit}-Shared
        volumeMounts:
        - name: dns-config
          mountPath: /etc/kubernetes
          readOnly: true
      volumes:
      - name: dns-config
        secret:
          secretName: dns-config
EOF
  filename = pathexpand("../aksplus_kubernetes/dns/external-dns.yaml")
}

data "azurerm_client_config" "this" {
}

resource "local_file" "dns_config" {
  content  = <<EOF
{
  "tenantId": "${data.azurerm_client_config.this.tenant_id}",
  "subscriptionId": "${data.azurerm_subscription.this.subscription_id}",
  "resourceGroup": "${var.business_unit}-Shared",
  "aadClientId": "${module.akssp.application_id}",
  "aadClientSecret": "${module.akssp.service_principal_password}"
}
EOF
  filename = pathexpand("../aksplus_kubernetes/dns/azure.json")
}

# GPU demo
resource "local_file" "gpu" {
  content  = <<EOF
enable_gpu = ${var.enable_gpu ? true : false}
EOF
  filename = pathexpand("../aksplus_kubernetes/gpu.auto.tfvars")
}

# GPU demo
resource "local_file" "windows" {
  content  = <<EOF
enable_windows = ${var.enable_windows ? true : false}
EOF
  filename = pathexpand("../aksplus_kubernetes/windows.auto.tfvars")
}
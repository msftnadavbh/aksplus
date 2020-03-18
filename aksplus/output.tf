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
  count    = var.enable_aad_rbac ? 1 : 0
  content  = <<EOF
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: dev-user-full-access
  namespace: dev
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["batch"]
  resources:
  - jobs
  - cronjobs
  verbs: ["*"]

---

kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: dev-user-access
  namespace: dev
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: dev-user-full-access
subjects:
- kind: Group
  namespace: dev
  name: ${var.appdev_object_id}

---

kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: sre-user-full-access
  namespace: sre
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["batch"]
  resources:
  - jobs
  - cronjobs
  verbs: ["*"]

---

kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: sre-user-access
  namespace: sre
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: sre-user-full-access
subjects:
- kind: Group
  namespace: sre
  name: ${var.opssre_object_id}

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user-access
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: ${var.admins_object_id}
EOF
  filename = pathexpand("../aksplus_kubernetes/aad_rbac/aad_rbac.yaml")
}

# Application gateway ingress controller
data "azurerm_subscription" "this" {
}

resource "local_file" "agic" {
  count    = var.enable_appgw ? 1 : 0
  content  = <<EOF
verbosityLevel: 3
appgw:
  subscriptionId: ${data.azurerm_subscription.this.subscription_id}
  resourceGroup: ${azurerm_resource_group.aksplus.name}
  name: ${var.business_unit}AGW
  usePrivateIP: false
  shared: false
kubernetes:
  watchNamespace: sre
armAuth:
  type: aadPodIdentity
  identityResourceID: ${module.aksui.identity_id}
  identityClientID:  ${module.aksui.identity_client_id}
rbac:
  enabled: true
aksClusterConfiguration:
  apiServerAddress: ${module.aks.fqdn}
EOF
  filename = pathexpand("../aksplus_kubernetes/agic/config.yaml")
}

resource "local_file" "dns_yaml" {
  count    = var.enable_dns ? 1 : 0
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
  count    = var.enable_dns ? 1 : 0
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

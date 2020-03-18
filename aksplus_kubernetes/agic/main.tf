locals {
  admin_config = pathexpand("~/.kube/admin_config")
}
provider "null" {
  version = "~> 2.1"
}

provider "helm" {
  version = "~> 1.0"
  kubernetes {
    config_path      = pathexpand("~/.kube/admin_config")
    load_config_file = true
  }
}

resource "null_resource" "aad_pod_identity" {
  count = var.enabled ? 1 : 0
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} apply -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment-rbac.yaml"
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} delete -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment-rbac.yaml"
    when    = destroy
  }
}

data "helm_repository" "agic" {
  name = "application-gateway-kubernetes-ingress"
  url  = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/"
}

/*
resource "null_resource" "agic" {
  count = var.enabled ? 1 : 0
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} create ns sre"
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} delete ns sre"
    when    = destroy
  }
  depends_on = [null_resource.aad_pod_identity]  
}
*/

resource "helm_release" "agic" {
  count = var.enabled ? 1 : 0
  name       = "agic"
  namespace  = "sre"
  repository = data.helm_repository.agic.metadata[0].name
  chart      = "application-gateway-kubernetes-ingress/ingress-azure"

  set {
    name  = "appgw.name"
    value = var.application_gateway_name
  }

  set {
    name  = "appgw.resourceGroup"
    value = var.resource_group_name
  }

  set {
    name  = "appgw.subscriptionId"
    value = var.subscription_id
  }

  set {
    name  = "appgw.usePrivateIP"
    value = false
  }

  set {
    name  = "appgw.shared"
    value = false
  }

  set {
    name  = "armAuth.type"
    value = "aadPodIdentity"
  }

  set {
    name  = "armAuth.identityResourceID"
    value = var.identity_id
  }

  set {
    name  = "armAuth.identityClientID"
    value = var.identity_client_id
  }

  set {
    name  = "rbac.enabled"
    value = true
  }

  set {
    name  = "kubernetes.watchNamespace"
    value = "sre"
  }

  set {
    name  = "aksClusterConfiguration.apiServerAddress"
    value = var.aks_fqdn
  }
  depends_on = [null_resource.aad_pod_identity]
}

/*
resource "null_resource" "cert_manager" {
  count = var.enabled ? 1 : 0
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} apply -f https://raw.githubusercontent.com/jetstack/cert-manager/v0.14.0/deploy/manifests/00-crds.yaml"
  }
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} create namespace cert-manager"
  }
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} label namespace cert-manager certmanager.k8s.io/disable-validation=true"
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} delete namespace cert-manager"
    when    = destroy
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} delete -f https://raw.githubusercontent.com/jetstack/cert-manager/v0.14.0/deploy/manifests/00-crds.yaml"
    when    = destroy
  }

  depends_on = [helm_release.agic]
}


data "helm_repository" "cert_manager" {  
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

resource "helm_release" "cert-manager" {
  count = var.enabled ? 1 : 0
  name       = "cert-manager"
  namespace  = "cert-manager"
  repository = data.helm_repository.cert_manager.metadata[0].name
  chart      = "jetstack/cert-manager"
  version    = "v0.14.0"
  depends_on = [null_resource.cert_manager]
}
*/

resource "null_resource" "issuers" {
  count = var.enabled ? 1 : 0
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} apply -f ${path.module}/issuers.yaml"
  }
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} delete -f ${path.module}/issuers.yaml"
    when    = destroy
  }

  depends_on = [helm_release.agic]
}
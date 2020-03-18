locals {
  admin_config = pathexpand("~/.kube/admin_config")
}
provider "null" {
  version = "~> 2.1"
}

resource "null_resource" "dns" {
  count = var.enabled ? 1 : 0

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} create ns external-dns"
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} create secret generic dns-config --from-file=${path.module}/azure.json --namespace external-dns"
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} apply -f ${path.module}/external-dns.yaml  --namespace external-dns"
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} delete -f ${path.module}/external-dns.yaml  --namespace external-dns"
    when    = destroy
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} delete secret dns-config  --namespace external-dns"
    when    = destroy
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} delete ns external-dns"
    when    = destroy
  }
}
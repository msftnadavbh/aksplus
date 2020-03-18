locals {
  admin_config = pathexpand("~/.kube/admin_config")
}
provider "null" {
  version = "~> 2.1"
}

resource "null_resource" "windows" {
  count = var.enabled ? 1 : 0

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} apply -f ${path.module}/windows_app.yaml"
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} delete -f ${path.module}/windows_app.yaml"
    when = destroy
  }
}
locals {
  admin_config = pathexpand("~/.kube/admin_config")
}
provider "null" {
  version = "~> 2.1"
}

resource "null_resource" "gpu" {
  count = var.enabled ? 1 : 0

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} create ns gpu"
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} apply -f ${path.module}/gpu_plugin.yaml"
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} apply -f ${path.module}/gpu_batch.yaml"
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} delete -f ${path.module}/gpu_batch.yaml"
    when = destroy
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} apply -f ${path.module}/gpu_plugin.yaml"
    when    = destroy
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local.admin_config} delete ns gpu"
    when    = destroy
  }
}
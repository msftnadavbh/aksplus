provider "kubernetes" {
  version          = "~> 1.11"
  config_path      = pathexpand("~/.kube/admin_config")
  load_config_file = true
}

locals {
  enable_aad_rbac = (var.enabled) && (var.appdev_object_id != "") && (var.opssre_object_id != "") && (var.admins_object_id != "")
}

resource "kubernetes_namespace" "dev" {
  count = local.enable_aad_rbac? 1: 0
  metadata {
    annotations = {
      name = "dev"
    }
    name = "dev"
  }
}

resource "kubernetes_namespace" "sre" {
  count = local.enable_aad_rbac? 1: 0
  metadata {
    annotations = {
      name = "sre"
    }
    name = "sre"
  }
}

resource "kubernetes_role" "dev" {
  count = local.enable_aad_rbac? 1: 0
  metadata {
    name      = "dev-user-full-access"
    namespace = "dev"
  }
  rule {
    api_groups = ["", "extensions", "apps"]
    resources  = ["*"]
    verbs      = ["*"]
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "dev" {
  count = local.enable_aad_rbac? 1: 0
  metadata {
    name      = "dev-user-access"
    namespace = "dev"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "dev-user-full-access"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    namespace = "dev"
    name      = var.appdev_object_id
  }
}

resource "kubernetes_role" "sre" {
  count = local.enable_aad_rbac? 1: 0
  metadata {
    name      = "dev-user-full-access"
    namespace = "sre"
  }
  rule {
    api_groups = ["", "extensions", "apps"]
    resources  = ["*"]
    verbs      = ["*"]
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "sre" {
  count = local.enable_aad_rbac? 1: 0
  metadata {
    name      = "sre-user-access"
    namespace = "dev"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "sre-user-full-access"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    namespace = "sre"
    name      = var.opssre_object_id
  }
}

resource "kubernetes_cluster_role_binding" "admin" {
  count = local.enable_aad_rbac? 1: 0
  metadata {
    name = "admin-user-access"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = var.admins_object_id
  }
}

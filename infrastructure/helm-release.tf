provider "helm" {
  kubernetes = {
    config_path    = pathexpand("~/.kube/config")
    config_context = "k3d-k3s-default"
  }
}

resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = "istio-system"
  values = [
    file("${path.module}/helm-release/istio/base.yaml")
  ]

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "helm_release" "istio_cni" {
  name       = "istio-cni"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "cni"
  namespace  = "istio-system"
  values = [
    file("${path.module}/helm-release/istio/cni.yaml")
  ]

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "helm_release" "istiod" {
  name       = "istio"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = "istio-system"
  values = [
    file("${path.module}/helm-release/istio/default.yaml")
  ]

  lifecycle {
    ignore_changes = [metadata]
  }

  depends_on = [
    helm_release.istio_cni
  ]
}

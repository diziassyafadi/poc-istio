provider "kubernetes" {
  config_path    = pathexpand("~/.kube/config")
  config_context = "k3d-k3s-default"
}

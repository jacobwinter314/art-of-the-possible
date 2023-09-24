locals {
  resource_group_name = "rg-artpossible-dev-westus"
  cluster_name = "aks-artpossible-dev-westus"
  acr_host_name = "crartpossibledevwestus.azurecr.io"
  acr_image_name = "art-of-the-possible"
  acr_image_tag = "0.5.0.1695566861"
}

data "azurerm_kubernetes_cluster" "k8s" {
  name                = local.cluster_name
  resource_group_name = local.resource_group_name
}

provider "kubernetes" {
  host                  = data.azurerm_kubernetes_cluster.k8s.kube_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)
}

provider "kubectl" {
  host                  = data.azurerm_kubernetes_cluster.k8s.kube_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)
  load_config_file = false
}

data "kubectl_path_documents" "deployment" {
    pattern = "./deployment.yaml"
    vars = {
        host_name = local.acr_host_name
        image_name = local.acr_image_name
        image_tag = local.acr_image_tag
    }
}

resource "kubectl_manifest" "deployment" {
    for_each  = toset(data.kubectl_path_documents.deployment.documents)
    yaml_body = each.value
}

resource "kubectl_manifest" "service" {
  depends_on = [ kubectl_manifest.deployment ]

  yaml_body = <<YAML
apiVersion: v1
kind: Service
metadata:
  name: art-of-the-possible
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 5000
  selector:
    app: art-of-the-possible
  YAML
}

resource "time_sleep" "wait_for_deployment" {
  depends_on = [ kubectl_manifest.service ]

  create_duration = "30s"
}

data "kubernetes_service" "example" {
  depends_on = [ time_sleep.wait_for_deployment ]
  metadata {
    name = "art-of-the-possible"
  }
}

output "webapp_cluster_ip" {
  value = data.kubernetes_service.example.status[0].load_balancer[0].ingress[0].ip
}

locals {
  ingress_nginx_namespace = "ingress-nginx"
}

# resource "terraform_data" "ingress_nginx" {
#   count = var.cluster_spec.deploy_ingress_nginx ? 1 : 0

#   provisioner "local-exec" {
#     command = <<-EOT
#     set -euo pipefail

#     export KUBECONFIG=$KUBECONFIG
#     kubectl config use-context $CONTEXT
#     kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

#     kubectl wait --namespace ${local.ingress_nginx_namespace} \
#       --for=condition=ready pod \
#       --selector=app.kubernetes.io/component=controller \
#       --timeout=90s
#     EOT

#     environment = {
#       "KUBECONFIG" = local.kubeconfig_path
#       "CONTEXT"    = local.context_name
#     }

#     when       = create
#     on_failure = continue
#   }

#   triggers_replace = sha256(kind_cluster.this.kubeconfig)
# }

module "ingress-nginx" {
  source = "../modules/ingress-nginx"

  additional_controller_args = ["--enable-ssl-passthrough"]

  depends_on = [kind_cluster.this]
}

# edit the ingress-nging deployment -default-server-tls-secret=$(POD_NAMESPACE)/[SECRET_NAME]
module "ingress-tls" {
  count  = var.cluster_spec.deploy_ingress_nginx ? 1 : 0
  source = "../modules/ingress-tls"

  dns_names = ["*.local.io"]
  subject = {
    common_name  = "*.local.io"
    organization = "Local Kubernetes"
  }

  secret_name      = "tls-default"
  secret_namespace = local.ingress_nginx_namespace

  depends_on = [kind_cluster.this]
}

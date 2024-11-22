module "ingress-nginx" {
  source = "../modules/ingress-nginx"

  additional_controller_args = ["--enable-ssl-passthrough"]
}

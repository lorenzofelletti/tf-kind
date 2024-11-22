resource "tls_private_key" "this" {
  algorithm = "ECDSA"
}

resource "tls_self_signed_cert" "this" {
  private_key_pem       = tls_private_key.this.private_key_pem
  validity_period_hours = var.validity_period_days * 24

  dns_names = var.dns_names

  subject {
    common_name         = var.subject.common_name
    organization        = var.subject.organization
    organizational_unit = var.subject.organizational_unit
  }

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "kubernetes_secret_v1" "cert" {
  metadata {
    name      = var.secret_name
    namespace = var.secret_namespace
  }

  data = {
    "tls.crt" = tls_self_signed_cert.this.cert_pem
    "tls.key" = tls_private_key.this.private_key_pem
  }
}

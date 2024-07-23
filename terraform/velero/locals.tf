locals {
  minio_secret_data = nonsensitive(<<-EOT
  [default]
  aws_access_key_id = ${minio_iam_service_account.velero.access_key}
  aws_secret_access_key = ${minio_iam_service_account.velero.secret_key}
  EOT
  )

  __values = var.velero.values_file != null ? [file(pathexpand(var.velero.values_file))] : var.velero.values
  values = [for v in local.__values : templatestring(v, {
    plugin_version  = "v1.10.0",
    minio_region    = "main",
    velero_svc_host = data.terraform_remote_state.cluster.outputs.minio_kubernetes_service.default_hostname,
    velero_svc_port = data.terraform_remote_state.cluster.outputs.minio_kubernetes_service.ports[0].port
  })]
}

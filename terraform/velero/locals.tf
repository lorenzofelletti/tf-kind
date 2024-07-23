locals {
  minio_secret_data = nonsensitive(<<-EOT
  [default]
  aws_access_key_id = ${minio_iam_service_account.velero.access_key}
  aws_secret_access_key = ${minio_iam_service_account.velero.secret_key}
  EOT
  )

  __values = var.velero.values_file != null ? [file(pathexpand(var.velero.values_file))] : var.velero.values
  values = [for v in local.__values : replace(replace(replace(replace(v,
    "{{PLUGIN_VERSION}}", "v1.10.0"),
    "{{MINIO_REGION}}", "main"),
    "{{VELERO_SVC_HOST}}", data.terraform_remote_state.cluster.outputs.minio_kubernetes_service.default_hostname),
    "{{VELERO_SVC_PORT}}", data.terraform_remote_state.cluster.outputs.minio_kubernetes_service.ports[0].port
  )]
}

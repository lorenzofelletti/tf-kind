locals {
  minio_secret_data = nonsensitive(<<-EOT
  [default]
  aws_access_key_id = ${minio_iam_service_account.velero.access_key}
  aws_secret_access_key = ${minio_iam_service_account.velero.secret_key}
  EOT
  )
}

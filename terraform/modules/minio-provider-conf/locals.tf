locals {
  minio_key_file = sensitive(
    jsondecode(file(pathexpand(var.minio_key_file)))
  )
  minio_credentials = {
    access_key = sensitive(local.minio_key_file.accessKey)
    secret_key = sensitive(local.minio_key_file.secretKey)
  }
}

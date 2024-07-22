resource "minio_s3_bucket" "this" {
  count = var.create_bucket ? 1 : 0

  bucket = var.bucket_name
}

resource "minio_s3_object" "upload" {
  object_name = var.object_name
  bucket_name = var.create_bucket ? minio_s3_bucket.this[0].bucket : var.bucket_name
  content     = var.content_to_upload
}

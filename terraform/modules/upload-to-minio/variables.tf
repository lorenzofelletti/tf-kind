variable "content_to_upload" {
  description = "The content to upload to Minio"
  type        = string
  nullable    = false
}

variable "object_name" {
  description = "The name of the object to upload the content to"
  type        = string
  default     = null

}

variable "bucket_name" {
  description = "The name of the bucket to upload the content to"
  type        = string
  nullable    = false
}

variable "create_bucket" {
  description = "Whether to create the bucket if it does not exist"
  type        = bool
  default     = false
  nullable    = false
}

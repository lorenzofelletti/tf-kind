# data "minio_iam_policy_document" "terraform-admin" {
#   provider = minio.bootstrap
#   id       = "terraform-admin"
#   source_json = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:*",
#         ]
#         Resource = [
#           "*",
#         ]
#       },
#     ]
#   })
# }

# resource "minio_iam_group" "terraform-admin" {
#   provider = minio.bootstrap
#   name     = "terraform-admin"


#   # policy = data.minio_iam_policy_document.terraform-admin.json
# }

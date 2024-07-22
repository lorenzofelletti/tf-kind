resource "minio_iam_group" "velero" {
  name = "velero-group"
}

resource "minio_iam_user" "velero" {
  name = "velero"
  tags = {
    managed_by = "terraform"
  }
}

resource "minio_iam_group_membership" "velero" {
  name  = "velero-group-membership"
  group = minio_iam_group.velero.name
  users = [minio_iam_user.velero.name]
}

resource "minio_iam_group_policy" "velero" {
  group = minio_iam_group.velero.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : ["s3:*"],
        "Resource" : ["arn:aws:s3:::*"]
      },
    ]
  })
}

resource "minio_iam_service_account" "velero" {
  target_user = minio_iam_user.velero.name
}

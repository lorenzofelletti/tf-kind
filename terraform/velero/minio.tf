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

resource "minio_iam_group_policy_attachment" "velero" {
  group_name  = minio_iam_group.velero.name
  policy_name = minio_iam_group_policy.velero.name
}

resource "minio_iam_service_account" "velero" {
  target_user = minio_iam_user.velero.name

  lifecycle {
    ignore_changes = [policy]
  }
}

resource "minio_iam_group_policy" "velero" {
  name   = "velero-group-policy"
  group  = minio_iam_group.velero.name
  policy = data.minio_iam_policy_document.velero.json
}

data "minio_iam_policy_document" "velero" {
  statement {
    effect  = "Allow"
    actions = ["admin:*"]
  }
  statement {
    effect  = "Allow"
    actions = ["kms:*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "admin:OBDInfo",
      "admin:Profiling",
      "admin:Prometheus",
      "admin:ServerInfo",
      "admin:ServerTrace",
      "admin:TopLocksInfo",
      "admin:BandwidthMonitor",
      "admin:ConsoleLog"
    ]
    resources = ["arn:aws:s3:::*"]
  }
}

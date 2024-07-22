velero = {
  version = "v7.1.1"
  values = [
    <<-EOT
    configuration:
      uploaderType: restic
      backupStorageLocation:
      - name: default
        provider: aws
        bucket: velero-backups
      volumeSnapshotLocation:
      - name: default
        provider: aws

    initContainers:
    - name: velero-plugin-for-aws
      image: velero/velero-plugin-for-aws:v1.10.0
      imagePullPolicy: IfNotPresent
      volumeMounts:
        - mountPath: /target
          name: plugins

    credentials:
      useSecret: false

    metrics:
      enabled: true
      scrapeInterval: 30s
      scrapeTimeout: 10s
      serviceMonitor:
        enabled: true
        autodetect: false
        namaspace: velero
        additionalLabels:
          Release: kube-prometheus-stack
    EOT
  ]
}

### --- Terraform Configuration --- ###

kubeconfig = {
  remote = {
    bucket_name = "cluster-kubeconfig"
    object_name = "kubeconfig"
  }
}

minio_key_file = "./credentials.json"

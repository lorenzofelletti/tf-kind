resource "terraform_data" "calico" {
  provisioner "local-exec" {
    when    = create
    command = <<-EOT
    export KUBECONFIG="${var.kubeconfig_path}"
    kubectl config use-context "${var.kubeconfig_context}"

    kubectl create -f ${local.calico_tigera_operator_manifest}
    kubectl create -f ${local.calico_custom_resources_manifest}
    EOT
  }

  triggers_replace = {
    kubeconfig_context               = var.kubeconfig_context
    calico_version                   = var.calico_version
    calico_tigera_operator_manifest  = local.calico_tigera_operator_manifest
    calico_custom_resources_manifest = local.calico_custom_resources_manifest
    additional_replace_trigger       = var.additional_replace_trigger
  }
}

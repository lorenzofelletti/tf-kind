locals {
  calico_tigera_operator_manifest = replace(
    var.manifest_url_template.tigera_operator,
    "{{CALICO_VERSION}}",
    var.calico_version
  )
  calico_custom_resources_manifest = replace(
    var.manifest_url_template.custom_resources,
    "{{CALICO_VERSION}}",
    var.calico_version
  )
}

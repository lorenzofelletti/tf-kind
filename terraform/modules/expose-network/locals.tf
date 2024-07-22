locals {
  name = replace(
    var.name_template,
    "{{NET_NAME}}",
    var.network_name
  )
  labels = { for k, v in var.labels : k => replace(v, "{{NET_NAME}}", var.network_name) }
}

locals {
  name = replace(
    var.name_template,
    "{{NET_NAME}}",
    var.network_name
  )
  labels = { for k, v in var.labels : k => replace(v, "{{NET_NAME}}", var.network_name) }

  __ports = flatten([for port in split(",", var.ports) : [
    for i in range(
      tonumber(split("-", port)[0]), tonumber(try(split("-", port)[1], split("-", port)[0])) + 1
    ) : i
  ]])
  ports = { for i, p in local.__ports : i => p }
}

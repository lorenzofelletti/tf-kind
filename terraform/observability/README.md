<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.14.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.31.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.kube_prometheus](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.monitoring](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_local_kubeconfig_path"></a> [local\_kubeconfig\_path](#input\_local\_kubeconfig\_path) | Local path to the kubeconfig file | <pre>object({<br>    path         = string<br>    context_name = optional(string)<br>  })</pre> | n/a | yes |
| <a name="input_observability"></a> [observability](#input\_observability) | Configuration for the observability module (based on kube-prometheus-stack) | <pre>object({<br>    namespace               = optional(string, "monitoring")<br>    kube_prometheus_name    = optional(string, "kube-prometheus-stack")<br>    kube_prometheus_version = string<br>    values                  = optional(list(string), [])<br>  })</pre> | n/a | yes |
| <a name="input_remote_kubeconfig_path"></a> [remote\_kubeconfig\_path](#input\_remote\_kubeconfig\_path) | Not supported yet, use local\_kubeconfig\_path instead.<br>Remote path to the kubeconfig file. Must be a MinIO path.<br>Fields:<br>- bucket\_name: The name of the bucket<br>- object\_name: The name of the object<br>- context\_name: The name of the context to use in the kubeconfig file (optional)<br>- store\_locally: The local path to store the kubeconfig file (default: /tmp/kubeconfig) | <pre>object({<br>    bucket_name   = string<br>    object_name   = string<br>    context_name  = optional(string)<br>    store_locally = optional(string, "/tmp/kubeconfig")<br>  })</pre> | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
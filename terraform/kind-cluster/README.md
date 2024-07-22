# Kind Cluster
Spin up a Kind Kubernetes cluster, with the option to use Calico for networking.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9 |
| <a name="requirement_kind"></a> [kind](#requirement\_kind) | ~> 0.5.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |
| <a name="requirement_minio"></a> [minio](#requirement\_minio) | ~> 2.3.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kind"></a> [kind](#provider\_kind) | 0.5.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_calico"></a> [calico](#module\_calico) | ./modules/install-calico | n/a |
| <a name="module_upload_kubeconfig"></a> [upload\_kubeconfig](#module\_upload\_kubeconfig) | ./modules/upload-to-minio | n/a |

## Resources

| Name | Type |
|------|------|
| [kind_cluster.this](https://registry.terraform.io/providers/tehcyx/kind/latest/docs/resources/cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_calico_version"></a> [calico\_version](#input\_calico\_version) | The version of Calico to install, if you chose to install Calico in the cluster | `string` | `null` | no |
| <a name="input_cluster_spec"></a> [cluster\_spec](#input\_cluster\_spec) | Specs of the cluster | <pre>object({<br>    name                      = optional(string, "cluster")<br>    k8s_version               = string<br>    wait_for_ready            = optional(bool, true)<br>    containerd_config_patches = optional(list(string), [])<br>    nodes = optional(map(object({<br>      role                   = optional(string, "worker")<br>      kubeadm_config_patches = optional(list(string), [])<br>    })), {})<br>    networking = optional(object({<br>      apiserver_port      = optional(number, null)<br>      disable_default_cni = optional(bool, null)<br>      install_calico      = optional(bool, false)<br>      ip_family           = optional(string, null)<br>      pod_subnet          = optional(string, null)<br>      service_subnet      = optional(string, null)<br>    }), null)<br>  })</pre> | <pre>{<br>  "k8s_version": "1.30.0"<br>}</pre> | no |
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Path to kubeconfig file | `string` | `"~/.kube/config"` | no |
| <a name="input_kubeconfig_upload_bucket_name"></a> [kubeconfig\_upload\_bucket\_name](#input\_kubeconfig\_upload\_bucket\_name) | The name of the bucket to upload the kubeconfig to. If not set, the kubeconfig will not be uploaded. | `string` | n/a | yes |
| <a name="input_minio_key_file"></a> [minio\_key\_file](#input\_minio\_key\_file) | Path to the file containing the MinIO access key and secret key | `string` | n/a | yes |
| <a name="input_minio_server"></a> [minio\_server](#input\_minio\_server) | The MinIO server to use for the S3 backend | `string` | `"localhost:9000"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_provider"></a> [cluster\_provider](#output\_cluster\_provider) | Provider of the cluster |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Kubeconfig file for the cluster |
<!-- END_TF_DOCS -->
# Install Calico
Installs Calico on a Kubernetes cluster.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [terraform_data.calico](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_calico_version"></a> [calico\_version](#input\_calico\_version) | The version of Calico to install | `string` | `"v3.28.0"` | no |
| <a name="input_kubeconfig_context"></a> [kubeconfig\_context](#input\_kubeconfig\_context) | Kubeconfig context to use | `string` | n/a | yes |
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Path to kubeconfig file | `string` | n/a | yes |
| <a name="input_manifest_url_template"></a> [manifest\_url\_template](#input\_manifest\_url\_template) | Default should be fine.<br>URL template for the Calico manifests. Template the Calico version with `{{CALICO_VERSION}}`.<br>The templated version would be replaced with the value of `calico_version` variable. | <pre>object({<br>    tigera_operator  = string<br>    custom_resources = string<br>  })</pre> | <pre>{<br>  "custom_resources": "https://raw.githubusercontent.com/projectcalico/calico/{{CALICO_VERSION}}/manifests/custom-resources.yaml",<br>  "tigera_operator": "https://raw.githubusercontent.com/projectcalico/calico/{{CALICO_VERSION}}/manifests/tigera-operator.yaml"<br>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
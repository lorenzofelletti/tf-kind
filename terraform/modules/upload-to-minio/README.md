# Upload to Minio
Uploads content to a Minio bucket. Content must be a string.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_minio"></a> [minio](#requirement\_minio) | >= 2.3.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_minio"></a> [minio](#provider\_minio) | >= 2.3.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [minio_s3_bucket.this](https://registry.terraform.io/providers/aminueza/minio/latest/docs/resources/s3_bucket) | resource |
| [minio_s3_object.upload](https://registry.terraform.io/providers/aminueza/minio/latest/docs/resources/s3_object) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the bucket to upload the content to | `string` | n/a | yes |
| <a name="input_content_to_upload"></a> [content\_to\_upload](#input\_content\_to\_upload) | The content to upload to Minio | `string` | n/a | yes |
| <a name="input_create_bucket"></a> [create\_bucket](#input\_create\_bucket) | Whether to create the bucket if it does not exist | `bool` | `false` | no |
| <a name="input_object_name"></a> [object\_name](#input\_object\_name) | The name of the object to upload the content to | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
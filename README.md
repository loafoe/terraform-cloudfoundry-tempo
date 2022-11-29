# terraform-cloudfoundry-tempo

Deploys a Grafana Tempo instance to Cloud foundry

## Usages

Checkout the example in [examples/default](./examples/default)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_cloudfoundry"></a> [cloudfoundry](#requirement\_cloudfoundry) | >= 0.14.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudfoundry"></a> [cloudfoundry](#provider\_cloudfoundry) | >= 0.14.2 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 2.2.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_proxy"></a> [proxy](#module\_proxy) | ./modules/proxy | n/a |

## Resources

| Name | Type |
|------|------|
| [cloudfoundry_app.tempo](https://registry.terraform.io/providers/cloudfoundry-community/cloudfoundry/latest/docs/resources/app) | resource |
| [cloudfoundry_network_policy.tempo](https://registry.terraform.io/providers/cloudfoundry-community/cloudfoundry/latest/docs/resources/network_policy) | resource |
| [cloudfoundry_route.tempo_internal](https://registry.terraform.io/providers/cloudfoundry-community/cloudfoundry/latest/docs/resources/route) | resource |
| [cloudfoundry_service_instance.s3](https://registry.terraform.io/providers/cloudfoundry-community/cloudfoundry/latest/docs/resources/service_instance) | resource |
| [random_id.id](https://registry.terraform.io/providers/random/latest/docs/resources/id) | resource |
| [cloudfoundry_domain.domain](https://registry.terraform.io/providers/cloudfoundry-community/cloudfoundry/latest/docs/data-sources/domain) | data source |
| [cloudfoundry_domain.internal](https://registry.terraform.io/providers/cloudfoundry-community/cloudfoundry/latest/docs/data-sources/domain) | data source |
| [cloudfoundry_service.s3](https://registry.terraform.io/providers/cloudfoundry-community/cloudfoundry/latest/docs/data-sources/service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cf_domain"></a> [cf\_domain](#input\_cf\_domain) | The CF domain to use for Grafana | `string` | n/a | yes |
| <a name="input_cf_space_id"></a> [cf\_space\_id](#input\_cf\_space\_id) | The CF Space to deploy in | `string` | n/a | yes |
| <a name="input_disk"></a> [disk](#input\_disk) | The amount of Disk space to allocate for Grafana Tempo (MB) | `number` | `4980` | no |
| <a name="input_enable_public_proxy"></a> [enable\_public\_proxy](#input\_enable\_public\_proxy) | Enables an authenticated public proxy endpoint | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment variables for Grafana Tempo | `map(any)` | `{}` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount of RAM to allocate for Grafana (MB) | `number` | `512` | no |
| <a name="input_name_postfix"></a> [name\_postfix](#input\_name\_postfix) | The postfix string to append to the hostname, prevents namespace clashes | `string` | `""` | no |
| <a name="input_network_policies"></a> [network\_policies](#input\_network\_policies) | The container-to-container network policies to create with Grafana as the source app | <pre>list(object({<br>    destination_app = string<br>    protocol        = string<br>    port            = string<br>  }))</pre> | `[]` | no |
| <a name="input_s3_broker_settings"></a> [s3\_broker\_settings](#input\_s3\_broker\_settings) | The S3 service broker to use | <pre>object({<br>    service_broker = string<br>    service_plan   = string<br>  })</pre> | <pre>{<br>  "service_broker": "hsdp-s3",<br>  "service_plan": "s3_bucket"<br>}</pre> | no |
| <a name="input_strategy"></a> [strategy](#input\_strategy) | The deployment strategy to use | `string` | `"rolling"` | no |
| <a name="input_tempo_image"></a> [tempo\_image](#input\_tempo\_image) | Tempo Docker image to use | `string` | `"loafoe/cf-tempo:v0.5.2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tempo_app_id"></a> [tempo\_app\_id](#output\_tempo\_app\_id) | The Tempo apps' id |
| <a name="output_tempo_internal_endpoint"></a> [tempo\_internal\_endpoint](#output\_tempo\_internal\_endpoint) | The internal endpoint where Tempo is reachable on |
| <a name="output_tempo_proxy_endpoint"></a> [tempo\_proxy\_endpoint](#output\_tempo\_proxy\_endpoint) | The endpoint where Tempo is reachable on |
| <a name="output_tempo_proxy_password"></a> [tempo\_proxy\_password](#output\_tempo\_proxy\_password) | The endpoint where Tempo is reachable on |
| <a name="output_tempo_proxy_username"></a> [tempo\_proxy\_username](#output\_tempo\_proxy\_username) | The endpoint where Tempo is reachable on |
<!-- END_TF_DOCS -->

## Contact / Getting help

Please post your questions on the HSDP Slack `#terraform` channel

## License

[License](./LICENSE.md) is MIT

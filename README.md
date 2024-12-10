# gcp-envoy-to-cloud-run-metadata-auth-tofu

Demonstrates how to configure EnvoyProxy on Cloud Run to authenticate to a backend service, also running on Cloud Run, using GCP’s metadata service for secure service-to-service authentication.

## Overview

This is a sample project that demonstrates how to configure [EnvoyProxy](https://www.envoyproxy.io/) on [Cloud Run](https://cloud.google.com/run) to authenticate to a backend service, also running on Cloud Run, using GCP’s metadata service for secure service-to-service authentication. The complete working solution can be deployed using Terraform/OpenTofu.

The primary purpose here is to demonstrate how to configure EnvoyProxy to authenticate to a backend service using GCP’s metadata service using the [GCP Authentication Filter](https://www.envoyproxy.io/docs/envoy/latest/configuration/http/http_filters/gcp_authn_filter).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_artifact_registry_repository.dockerhub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_artifact_registry_repository.repo](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_cloud_run_service_iam_member.envoy_anonymous_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam_member) | resource |
| [google_cloud_run_service_iam_member.envoy_invoke_backend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam_member) | resource |
| [google_cloud_run_v2_service.backend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service) | resource |
| [google_cloud_run_v2_service.envoy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service) | resource |
| [google_service_account.backend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.envoy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_storage_bucket.config](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.envoy_read_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_object.envoy_config](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [random_uuid.bucket_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Name of the application used to prefix resources | `string` | `"envoytest"` | no |
| <a name="input_backend_image"></a> [backend\_image](#input\_backend\_image) | Docker image name to deploy to the backend in the format of <repository>/<image>:<tag> | `string` | `"unitvectory-labs/hellorest:v1"` | no |
| <a name="input_envoy_proxy_version"></a> [envoy\_proxy\_version](#input\_envoy\_proxy\_version) | Envoy Proxy version to deploy; matches the tag of the Docker image | `string` | `"v1.31.2"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to deploy resources | `string` | `"us-east1"` | no |
| <a name="input_repository_url"></a> [repository\_url](#input\_repository\_url) | Public Docker repository URL to pull images from (Default: ghcr.io) | `string` | `"https://ghcr.io"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_url"></a> [backend\_url](#output\_backend\_url) | The URL of the backend Cloud Run service that requires authentication to access and will return a 403 Error: Forbidden from Cloud Run |
| <a name="output_envoy_url"></a> [envoy\_url](#output\_envoy\_url) | The URL of the Envoy Proxy Cloud Run service that will forward requests to the backend service and allow anonymous access to the backend service returning a 200 OK |
<!-- END_TF_DOCS -->

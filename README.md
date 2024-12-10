# gcp-envoy-to-cloud-run-metadata-auth-tofu

Demonstrates how to configure EnvoyProxy on Cloud Run to authenticate to a backend service, also running on Cloud Run, using GCP’s metadata service for secure service-to-service authentication.

## Overview

This is a sample project that demonstrates how to configure [EnvoyProxy](https://www.envoyproxy.io/) on [Cloud Run](https://cloud.google.com/run) to authenticate to a backend service, also running on Cloud Run, using GCP’s metadata service for secure service-to-service authentication. The complete working solution can be deployed using Terraform/OpenTofu.

The primary purpose here is to demonstrate how to configure EnvoyProxy to authenticate to a backend service using GCP’s metadata service using the [GCP Authentication Filter](https://www.envoyproxy.io/docs/envoy/latest/configuration/http/http_filters/gcp_authn_filter).

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

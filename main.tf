
# Artifact Registry needed for Deployments

resource "google_artifact_registry_repository" "dockerhub" {
  location      = var.region
  project       = var.project_id
  repository_id = "${var.app_name}-docker"
  description   = "Proxy Container Registry for ${var.app_name} for Docker Hub"
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"

  remote_repository_config {
    docker_repository {
      public_repository = "DOCKER_HUB"
    }
  }
}

resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  project       = var.project_id
  repository_id = "${var.app_name}-repo"
  description   = "Proxy Container Registry for ${var.app_name}"
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"

  remote_repository_config {
    docker_repository {
      custom_repository {
        uri = var.repository_url
      }
    }
  }
}

# Create a bucket for the backend

resource "random_uuid" "bucket_suffix" {
  # Generate a random UUID to append to the bucket name to ensure uniqueness
}

resource "google_storage_bucket" "config" {
  project  = var.project_id
  location = var.region
  name     = "${var.app_name}-config-${random_uuid.bucket_suffix.result}"
}

# The Service Accounts used by Cloud Run

resource "google_service_account" "envoy" {
  project      = var.project_id
  account_id   = "${var.app_name}-envoy-sa"
  display_name = "${var.app_name} Service Account for EnvoyProxy"
}

resource "google_service_account" "backend" {
  project      = var.project_id
  account_id   = "${var.app_name}-backend-sa"
  display_name = "${var.app_name} Service Account for Backend"
}

# Grant the Service Accounts the necessary permissions

resource "google_storage_bucket_iam_member" "envoy_read_bucket" {
  # Grant the Cloud Run Service Account for Envoy Read permissions to the bucket where the configuration is stored
  bucket = google_storage_bucket.config.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.envoy.email}"
}

resource "google_cloud_run_service_iam_member" "envoy_invoke_backend" {
  # Grant the Cloud Run Service Account for Envoy the necessary permissions to invoke the Backend service in Cloud Run
  project  = var.project_id
  location = var.region
  service  = google_cloud_run_v2_service.backend.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.envoy.email}"
}

resource "google_cloud_run_service_iam_member" "envoy_anonymous_access" {
  # Allow Anonymous Access to the Envoy Proxy Service
  project  = var.project_id
  location = var.region
  service  = google_cloud_run_v2_service.envoy.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Create the Configuration for the Envoy Proxy from the Template

locals {
  template = templatefile("${path.module}/envoy-template.yaml", {
    # EnvoyProxy needs to know the URL of the backend service from Cloud Run
    BACKEND_DOMAIN = trimprefix(google_cloud_run_v2_service.backend.uri, "https://")
  })

  # We use a hash of the template to trigger a redeployment when the template changes
  template_hash = sha256(local.template)
}

resource "google_storage_bucket_object" "envoy_config" {
  # Store the configuration in a bucket to be read by the Envoy Proxy
  name    = "envoy.yaml"
  bucket  = google_storage_bucket.config.name
  content = local.template
}

# Deploy the Cloud Run Services (EnvoyProxy and Backend)

resource "google_cloud_run_v2_service" "envoy" {
  name     = "${var.app_name}-envoy"
  project  = var.project_id
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  deletion_protection = false

  template {
    service_account = google_service_account.envoy.email

    volumes {
      name = "config"
      gcs {
        bucket    = google_storage_bucket.config.name
        read_only = true
      }
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.app_name}-docker/envoyproxy/envoy:${var.envoy_proxy_version}"

      ports {
        container_port = 8080
      }

      volume_mounts {
        # Mount the configuration from the bucket
        name       = "config"
        mount_path = "/mnt/config"
      }

      # Tell Envoy to use the configuration file
      args = [
        "-c",
        "/mnt/config/envoy.yaml"
      ]

      # Trigger a redeployment when the configuration changes
      env {
        name  = "CONFIG_HASH"
        value = local.template_hash
      }
    }

  }

  depends_on = [
    google_artifact_registry_repository.dockerhub
  ]
}

resource "google_cloud_run_v2_service" "backend" {
  name     = "${var.app_name}-backend"
  project  = var.project_id
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  deletion_protection = false

  template {
    service_account = google_service_account.backend.email

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.app_name}-repo/${var.backend_image}"

      ports {
        container_port = 8080
      }
    }

  }

  depends_on = [
    google_artifact_registry_repository.repo
  ]
}
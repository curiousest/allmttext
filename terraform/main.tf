# main.tf

terraform {
  required_version = ">= 0.13"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.42"
    }
  }
  backend "gcs" {
    bucket = "terraform-state-allmytext"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_cloud_run_v2_job" "job" {
  name     = var.service_name
  location = var.region

  template {
    template {
      containers {
        image = "${var.image_name}:${var.image_tag}"

        env {
          name  = "GCS_BUCKET_NAME"
          value = var.gcs_bucket_name
        }

        env {
          name  = "PINECONE_INDEX_NAME"
          value = var.pinecone_index_name
        }

        env {
          name  = "PINECONE_ENVIRONMENT"
          value = var.pinecone_environment
        }

        env {
          name  = "GCP_PROJECT_ID"
          value = var.project_id
        }

        env {
          name = "OPENAI_API_KEY"
          value_source {
            secret_key_ref {
              secret  = var.openai_api_key_secret
              version = "latest"
            }
          }
        }

        env {
          name = "PINECONE_API_KEY"
          value_source {
            secret_key_ref {
              secret  = var.pinecone_api_key_secret
              version = "latest"
            }
          }
        }
      }
      service_account        = google_service_account.cloud_run_sa.email
      execution_environment  = "EXECUTION_ENVIRONMENT_GEN2"
    }
  }
}

resource "google_cloud_scheduler_job" "scheduler_job" {
  name             = "trigger-cloud-run-job"
  description      = "Triggers the Cloud Run Job periodically"
  schedule         = "0 0 * * 0"  # Adjust the cron schedule as needed
  time_zone        = "Etc/UTC"    # Adjust time zone if necessary
  attempt_deadline = "320s"

  http_target {
    http_method = "POST"
    uri         = "https://${var.region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project_id}/jobs/${var.service_name}:run"

    oauth_token {
      service_account_email = google_service_account.scheduler_sa.email
      scope                 = "https://www.googleapis.com/auth/cloud-platform"
    }

    headers = {
      "Content-Type" = "application/json"
    }
  }
}

resource "google_project_iam_member" "cloud_run_sa_secretmanager_secret_accessor" {
  project = var.project_id
  role = "roles/secretmanager.secretAccessor" 
  member = "serviceAccount:${var.cloud_run_sa_email}"
}

resource "google_service_account" "scheduler_sa" {
  account_id   = "cloud-scheduler-sa"
  display_name = "Cloud Scheduler Service Account"
}

resource "google_project_iam_member" "scheduler_sa_scheduler_agent" {
  project = var.project_id
  role    = "roles/cloudscheduler.serviceAgent"
  member  = "serviceAccount:${google_service_account.scheduler_sa.email}"
}

# Define the Cloud Run Job service account
resource "google_service_account" "cloud_run_sa" {
  account_id   = "cloud-run-job-sa"
  display_name = "Cloud Run Job Service Account"
}

# Assign roles to the Cloud Run Job service account
resource "google_project_iam_member" "cloud_run_sa_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_project_iam_member" "cloud_run_sa_storage_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_secret_manager_secret" "openai_api_key" {
  secret_id = var.openai_api_key_secret

  replication {
    auto {}
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_secret_manager_secret_version" "openai_api_key_version" {
  secret      = google_secret_manager_secret.openai_api_key.id
  secret_data = var.openai_api_key
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_secret_manager_secret" "pinecone_api_key" {
  secret_id = var.pinecone_api_key_secret

  replication {
    auto {}
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_secret_manager_secret_version" "pinecone_api_key_version" {
  secret      = google_secret_manager_secret.pinecone_api_key.id
  secret_data = var.pinecone_api_key
  lifecycle {
    prevent_destroy = true
  }
}


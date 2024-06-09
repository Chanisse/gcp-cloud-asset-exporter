# Asset Exporter Service Account
resource "google_service_account" "asset_export_sa" {
  project      = var.project_id
  account_id   = var.service_account_name
  display_name = "${var.service_account_name} Service Account"
}

# Asset Exporter BigQuery Dataset
resource "google_bigquery_dataset" "cloud_asset_inventory" {
  project                     = var.project_id
  dataset_id                  = "cloud_asset_inventory"
  friendly_name               = "Cloud Asset Inventory"
  description                 = "A dataset to store cloud asset inventory data"
  location                    = var.bq_location
  default_table_expiration_ms = null
}

# BigQuery Dataset Level IAM
resource "google_bigquery_dataset_iam_member" "asset_exporter_role" {
  for_each   = toset(var.bq_dataset_level_roles)
  project    = var.project_id
  dataset_id = google_bigquery_dataset.cloud_asset_inventory.dataset_id
  role       = each.value
  member     = "serviceAccount:${google_service_account.asset_export_sa.email}"
  depends_on = [google_service_account.asset_export_sa]
}

# Project level IAM
resource "google_project_iam_member" "asset_exporter_roles" {
  for_each = toset(var.project_level_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.asset_export_sa.email}"

  depends_on = [google_service_account.asset_export_sa]
}

# Org level IAM
resource "google_organization_iam_member" "asset_exporter_roles" {
  for_each = toset(var.org_level_roles)
  org_id   = var.org_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.asset_export_sa.email}"

  depends_on = [google_service_account.asset_export_sa]
}

# PubSub Topic
resource "google_pubsub_topic" "asset_export_pubsub_topic" {
  project = var.project_id
  name    = var.pubsub_topic_name
}

# Cloud Scheduler Job
resource "google_cloud_scheduler_job" "asset_export_scheduler_job" {
  project   = var.project_id
  region    = var.region
  name      = var.cloud_scheduler_name
  schedule  = var.cloud_scheduler_cron
  time_zone = "UTC"


  pubsub_target {
    topic_name = google_pubsub_topic.asset_export_pubsub_topic.id

    data = base64encode(jsonencode({
      message = {
        _comment = "Minimal pubsub message"
        data     = ""
      }
      type   = "google.cloud.pubsub.topic.v1.messagePublished"
      source = "//pubsub.googleapis.com/"
    }))
  }
}

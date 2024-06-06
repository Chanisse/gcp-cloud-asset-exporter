variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "Region for GCP services"
}

variable "org_id" {
  type        = string
  description = "GCP Organisation ID"
}

variable "project_level_roles" {
  type        = list(string)
  description = "List of IAM roles to assign to service account at project level"
}

variable "org_level_roles" {
  type        = list(string)
  description = "List of IAM roles to assign to service account at org level"
}

variable "bq_dataset_level_roles" {
  type        = list(string)
  description = "List of IAM roles to assign to service account for the BigQuery dataset"
}

variable "bq_location" {
  type        = string
  description = "Location for BigQuery dataset"
  default     = "europe-west2"
}

variable "service_account_name" {
  type        = string
  description = "Service account ID"
}

variable "pubsub_topic_name" {
  type        = string
  description = "Name of PubSub topic"
}

variable "cloud_scheduler_name" {
  type        = string
  description = "Name of Cloud Scheduler"
}

variable "cloud_scheduler_cron" {
  type        = string
  description = "Cron schedule for Cloud scheduler"
}
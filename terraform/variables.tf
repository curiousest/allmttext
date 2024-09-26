# variables.tf

variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "The Google Cloud region"
  type        = string
  default     = "us-central1"  # Change as needed
}

variable "service_name" {
  description = "Name of the Cloud Run Job"
  type        = string
}

variable "image_name" {
  description = "Docker image to deploy"
  type        = string
}

variable "cloud_run_sa_email" {
  description = "Service account email for Cloud Run Job"
  type        = string
}

variable "openai_api_key_secret" {
  description = "Name of the OpenAI API key secret in Secret Manager"
  type        = string
}

variable "pinecone_api_key_secret" {
  description = "Name of the Pinecone API key secret in Secret Manager"
  type        = string
}

variable "gcs_bucket_name" {
  description = "Name of the GCS bucket"
  type        = string
}

variable "pinecone_environment" {
  description = "Pinecone environment"
  type        = string
}

variable "pinecone_index_name" {
  description = "Pinecone index name"
  type        = string
}

variable "openai_api_key" {
  description = "The OpenAI API key"
  type        = string
  sensitive   = true
}

variable "pinecone_api_key" {
  description = "The Pinecone API key"
  type        = string
  sensitive   = true
}

variable "image_tag" {
  description = "Tag of the Docker image to deploy"
  type        = string
  default     = "latest"  # Set a default value
}

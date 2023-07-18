variable "cloud_provider" {
  default = "AWS"
}

variable "environment_name" {
  default = "ccloud-dr-test"
}

variable "region" {
  default = "us-east-2"
}

variable "schema_registry_package" {
  default = "ESSENTIALS"
}

variable "primary_cluster_name" {
  default = "primary_cluster"
}

variable "dr_cluster_name" {
  default = "dr_cluster"
}

variable "primary_cluster_availability_zone" {
  default = "SINGLE_ZONE"
}

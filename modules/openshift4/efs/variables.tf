variable "efs_encrypted" {
  default = "true"
}
variable "efs_performance_mode" {
  default = "generalPurpose"
}
variable "efs_throughput_mode" {
  default = "bursting"
}
variable "efs_tag_name" {}
variable "efs_tag_environment" {}
variable "efs_security_groups" {}
variable "efs_creation_token" {}
variable "efs_subnet_count" {}
variable "efs_subnet_filter" {}
variable "vpc" {}

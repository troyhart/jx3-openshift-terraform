variable "nlb_api_name" {} 
variable "load_balancer_type" {
  default = "network"
}
variable "internal" {
  default = "true"
}
variable "enable_cross_zone_load_balancing" {
  default = "true"
}
variable "enable_deletion_protection" {
  default = "false"
}
variable "tag_name" {
  default = "openshift-api-nlb"
}
variable "subnet_filter" {}
variable "tag_environment" {}
variable "tag_project" {}
variable "tag_role" {
  default = "network load balancer"
}
variable "nlb_target_group_name" {}
variable "target_group_port" {
  default = "443"
}
variable "target_group_protocol" {
  default = "TCP"
}
variable "target_group_type" {
  default = "ip"
}
variable "vpc" {}
variable "listener_port" {
  default = "443"
}
variable "listener_protocol" { 
  default = "TCP"
}
variable "listener_type" {
  default = "forward"
}
variable "target_group_attachement_port" {
  default = "443"
}
variable "subnet_count" {
  default = "3"
}
variable "zone_id" {}
variable "dns_suffix" {}
variable "clusterid" {}
variable "cluster_name" {}

module "nlb-okd-api" {
  vpc                           = "openshift-test"
  source                        = "../../../../modules/openshift4/nlb_api"
  tag_name                      = "${var.clusterid}-api"
  tag_environment               = "swe-test"
  tag_project                   = "swe-test"
  zone_id                       = "Z10101813MADIGPS9WDEJ"
  dns_suffix                    = "swe-test.aws.myriad.com"
  nlb_target_group_name         = "${var.clusterid}-tg"
  target_group_attachement_port = "6443"
  nlb_api_name                  = "${var.clusterid}-api"
  subnet_filter                 = "vpc/test/private-Subnet*"
  clusterid                     = var.clusterid
  cluster_name                  = var.cluster_name
}
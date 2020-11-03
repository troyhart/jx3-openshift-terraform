data "aws_vpc" "selected" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_security_group" "efs" {
  vpc_id = data.aws_vpc.selected.id
  tags = {
    Name = "${var.efs_sg_name}-${var.clusterid}"
  }
}
module "efs" {
    source = "../../../modules/openshift4/efs"

    efs_tag_name        = "${var.clusterid}-openshift-cluster"
    efs_tag_environment = "swe-test"
    efs_security_groups = data.aws_security_group.efs.id
    efs_creation_token  = var.clusterid
    efs_subnet_count    = "3"
    efs_subnet_filter   = "vpc/test/private-Subnet"
    vpc                 = "openshift-test"
}

output "filesystem_id" {
  value = "${module.efs.filesystem_id}"
}
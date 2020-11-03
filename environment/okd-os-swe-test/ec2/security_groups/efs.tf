module "efs-security-group" {

  source = "terraform-aws-modules/security-group/aws"
  version = "3.16.0"

  name = "openshift-efs-${var.clusterid}"
  description = "Openshift Cluster efs Security Group"
  vpc_id = data.aws_vpc.selected.id

  egress_with_cidr_blocks = [
    {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
      description = "Allow all outbound traffic by default"
      cidr_blocks = var.any_cidr
    }
  ]
  ingress_with_cidr_blocks = [
    {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
      description = "Allow vpc cidr"
      cidr_blocks = var.vpc_cidr
    }
  ]
}

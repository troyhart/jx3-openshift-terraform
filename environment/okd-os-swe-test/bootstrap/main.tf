data "aws_vpc" "selected" {
  tags = {
    Name = var.vpc_name
  }
}
data "aws_subnet_ids" "selected" {
  vpc_id = data.aws_vpc.selected.id
  tags = {
    Name = var.subnet_tag_name
  }
}
data "aws_subnet" "selected" {
  for_each = data.aws_subnet_ids.selected.ids
  id       = each.value
}
data "aws_security_group" "bootstrap" {
  vpc_id = data.aws_vpc.selected.id
  tags = {
    Name = "${var.bootstrap_sg_name}-${var.clusterid}"
  }
}

locals {

  bootstrap_data = <<EOF
{"ignition":{"config":{"replace":{"source":"s3://openshift-ign/s3loc.ign","verification":{}}},"timeouts":{},"version":"3.0.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}
EOF

}

module "bootstrap" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "2.15.0"

  name                        = "bootstrap-${var.clusterid}"
  instance_count              = "1"

  ami                         = var.ami
  instance_type               = "m5.xlarge"
  key_name                    = var.key_name
  associate_public_ip_address = false
  monitoring                  = false
  vpc_security_group_ids      = [ data.aws_security_group.bootstrap.id ]
  subnet_ids                  = tolist(data.aws_subnet_ids.selected.ids)
  user_data_base64            = base64encode(local.bootstrap_data)
  #iam_instance_profile        = var.bootstrap_instance_profile
  iam_instance_profile        = "openshift-ign"
 
  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 200
    },
  ]

  tags = {
    Project           = "openshift"
    Environment       = "swe-test"
    Role              = "bootstrap"
    "kubernetes.io/cluster/${var.clusterid}" = "owned"
  }

}
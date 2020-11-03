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

data "aws_security_group" "master" {
  vpc_id = data.aws_vpc.selected.id
  tags = {
    Name = "${var.master_sg_name}-${var.clusterid}"
  }
}

data "aws_security_group" "worker" {
  vpc_id = data.aws_vpc.selected.id
  tags = {
    Name = "${var.worker_sg_name}-${var.clusterid}"
  }
}

locals {

  master_data = <<EOF
{"ignition":{"config":{"replace":{"source":"s3://openshift-ign/master.ign","verification":{}}},"timeouts":{},"version":"3.0.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}
EOF

  worker_data = <<EOF
{"ignition":{"config":{"replace":{"source":"s3://openshift-ign/worker.ign","verification":{}}},"timeouts":{},"version":"3.0.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}
EOF

}

module "masters" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "2.15.0"

  name                        = "master-${var.clusterid}"
  instance_count              = "3"

  ami                         = var.ami
  instance_type               = "m5.xlarge"
  key_name                    = var.key_name
  associate_public_ip_address = false
  monitoring                  = false
  vpc_security_group_ids      = [ data.aws_security_group.master.id ]
  subnet_ids                  = tolist(data.aws_subnet_ids.selected.ids)
  user_data_base64            = base64encode(local.master_data)
  #iam_instance_profile        = var.master_instance_profile
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
    Role              = "master"
    "kubernetes.io/cluster/${var.clusterid}" = "owned"
  }
}

module "worker" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "2.15.0"

  name                        = "worker-${var.clusterid}"
  instance_count              = "3"

  ami                         = var.ami
  instance_type               = "m5.xlarge"
  key_name                    = var.key_name
  associate_public_ip_address = false
  monitoring                  = false
  vpc_security_group_ids      = [ data.aws_security_group.worker.id ]
  subnet_ids                  = tolist(data.aws_subnet_ids.selected.ids)
  user_data_base64            = base64encode(local.worker_data)
  #iam_instance_profile        = var.worker_instance_profile
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
    Role              = "worker"
    #KubernetesCluster = var.clusterid
    "kubernetes.io/cluster/${var.clusterid}" = "owned"
  }
}

data "aws_vpc" "selected" {
  tags = {
    Name = var.vpc
  }
}
data "aws_subnet_ids" "selected" {
  vpc_id = data.aws_vpc.selected.id
  tags = {
    Name   = var.efs_subnet_filter
  }
}
resource "aws_efs_file_system" "openshift_pv" {
  creation_token   = var.efs_creation_token
  encrypted        = var.efs_encrypted
  performance_mode = var.efs_performance_mode
  throughput_mode  = var.efs_throughput_mode

  tags = {
    Name        = var.efs_tag_name
    Environment = var.efs_tag_environment
  }
}

resource "aws_efs_mount_target" "openshift_pv" {
  count               = length(data.aws_subnet_ids.selected.ids)
  file_system_id      = aws_efs_file_system.openshift_pv.id
  subnet_id           = sort(data.aws_subnet_ids.selected.ids)[count.index]
  security_groups     = [ var.efs_security_groups ]
}


data "aws_vpc" "selected" {
  tags = {
    Name              = var.vpc_name
  }
}

module "master-security-group" {

  source = "terraform-aws-modules/security-group/aws"
  version = "3.16.0"

  name = "openshift-master-${var.clusterid}"
  description = "Openshift Cluster Master Security Group"
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
      from_port = 8
      to_port   = -1 
      protocol  = "icmp"
      description = "icmp"
      cidr_blocks = var.vpc_cidr
    },
    {
      from_port = 22
      to_port   = 22
      protocol  = "tcp"
      description = "Allow any openshift internal"
      cidr_blocks = "${var.vpc_cidr},${var.office_cidr},${var.openvpn_cidr}"
    },
    {
      from_port = 6443
      to_port   = 6443
      protocol  = "tcp"
      description = "Allow Any 6443 "
      cidr_blocks = "${var.vpc_cidr},${var.office_cidr},${var.openvpn_cidr}"
    },
    {
      from_port = 22623
      to_port   = 22623
      protocol  = "tcp"
      description = "Allow Any 22623"
      cidr_blocks = var.vpc_cidr
    }
  ] 
  ingress_with_source_security_group_id = [
    {
      from_port                = 10250
      to_port                  = 10259
      protocol                 = "tcp"
      description              = "Kubernetes kubelet, scheduler, controller"
      source_security_group_id = module.master-security-group.this_security_group_id
    },
    {
      from_port                = 10250
      to_port                  = 10259
      protocol                 = "tcp"
      description              = "Kubernetes kubelete, scheduler, controller"
      source_security_group_id = module.worker-security-group.this_security_group_id
    },
    {
      from_port                = 30000
      to_port                  = 32767
      protocol                 = "tcp"
      description              = "Kubernetes ingress services"
      source_security_group_id = module.master-security-group.this_security_group_id
    },
    {
      from_port                = 30000
      to_port                  = 32767
      protocol                 = "tcp"
      description              = "Kubernetes ingress services"
      source_security_group_id = module.worker-security-group.this_security_group_id
    },
    {
      from_port                = 30000
      to_port                  = 32767
      protocol                 = "udp"
      description              = "Kubernetes ingress services"
      source_security_group_id = module.master-security-group.this_security_group_id
    },
    {
      from_port                = 30000
      to_port                  = 32767
      protocol                 = "udp"
      description              = "Kubernetes ingress services"
      source_security_group_id = module.worker-security-group.this_security_group_id
    }, 
    {
      from_port                = 6081
      to_port                  = 6081
      protocol                 = "udp"
      description              = "Geneve packets"
      source_security_group_id = module.master-security-group.this_security_group_id
    },
    {
      from_port                = 6081
      to_port                  = 6081
      protocol                 = "udp"
      description              = "Geneve packets"
      source_security_group_id = module.worker-security-group.this_security_group_id
    },
    {
      from_port                = 2379
      to_port                  = 2380
      protocol                 = "tcp"
      description              = "etcd"
      source_security_group_id = module.master-security-group.this_security_group_id
    },
    {
      from_port                = 9000
      to_port                  = 9999
      protocol                 = "tcp"
      description              = "Internal cluster communication"
      source_security_group_id = module.master-security-group.this_security_group_id
    },
    {
      from_port                = 9000
      to_port                  = 9999
      protocol                 = "tcp"
      description              = "Internal cluster communication"
      source_security_group_id = module.worker-security-group.this_security_group_id
    },
    {
      from_port                = 9000
      to_port                  = 9999
      protocol                 = "udp"
      description              = "Internal cluster communication"
      source_security_group_id = module.master-security-group.this_security_group_id
    },
    {
      from_port                = 9000
      to_port                  = 9999
      protocol                 = "udp"
      description              = "Internal cluster communication"
      source_security_group_id = module.worker-security-group.this_security_group_id
    },
    {
      from_port                = 4789
      to_port                  = 4789
      protocol                 = "udp"
      description              = "Vxlan packets"
      source_security_group_id = module.master-security-group.this_security_group_id
    },
    {
      from_port                = 4789
      to_port                  = 4789
      protocol                 = "udp"
      description              = "Vxlan packets"
      source_security_group_id = module.worker-security-group.this_security_group_id
    }   
  ]
}

module "worker-security-group" {

  source = "terraform-aws-modules/security-group/aws"
  version = "3.16.0"

  name = "openshift-worker-${var.clusterid}"
  description = "Openshift Cluster Worker Security Group"
  vpc_id = data.aws_vpc.selected.id
  tags = {
    "kubernetes.io/cluster/${var.clusterid}" = "owned"
  }

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
      from_port = 8 
      to_port   = -1
      protocol  = "icmp"
      description = "icmp"
      cidr_blocks = var.any_cidr
    },
    {
      from_port = 22
      to_port   = 22
      protocol  = "tcp"
      description = "Allow ssh openshift worker"
      cidr_blocks = "${var.vpc_cidr},${var.office_cidr},${var.openvpn_cidr}"
    }
  ]  
  ingress_with_source_security_group_id = [
    {
      from_port                = 30000
      to_port                  = 32767
      protocol                 = "tcp"
      description              = "Kubernetes ingress services"
      source_security_group_id = module.master-security-group.this_security_group_id
    },
    {
      from_port                = 30000
      to_port                  = 32767
      protocol                 = "tcp"
      description              = "Kubernetes ingress services"
      source_security_group_id = module.worker-security-group.this_security_group_id
    },
    {
      from_port                = 30000
      to_port                  = 32767
      protocol                 = "udp"
      description              = "Kubernetes ingress services"
      source_security_group_id = module.master-security-group.this_security_group_id
    },
    {
      from_port                = 30000
      to_port                  = 32767
      protocol                 = "udp"
      description              = "Kubernetes ingress services"
      source_security_group_id = module.worker-security-group.this_security_group_id
    }, 
    {
      from_port                = 6081
      to_port                  = 6081
      protocol                 = "udp"
      description              = "Geneve packets"
      source_security_group_id = module.master-security-group.this_security_group_id
    },
    {
      from_port                = 6081
      to_port                  = 6081
      protocol                 = "udp"
      description              = "Geneve packets"
      source_security_group_id = module.worker-security-group.this_security_group_id
    },
    {
      from_port                = 9000
      to_port                  = 9999
      protocol                 = "tcp"
      description              = "Internal cluster communication"
      source_security_group_id = module.master-security-group.this_security_group_id
    },
    {
      from_port                = 9000
      to_port                  = 9999
      protocol                 = "tcp"
      description              = "Internal cluster communication"
      source_security_group_id = module.worker-security-group.this_security_group_id
    },
    {
      from_port                = 9000
      to_port                  = 9999
      protocol                 = "udp"
      description              = "Internal cluster communication"
      source_security_group_id = module.master-security-group.this_security_group_id
    },
    {
      from_port                = 9000
      to_port                  = 9999
      protocol                 = "udp"
      description              = "Internal cluster communication"
      source_security_group_id = module.worker-security-group.this_security_group_id
    },
    {
      from_port                = 10250
      to_port                  = 10250
      protocol                 = "tcp"
      description              = "kubernetes secure kubelet port"
      source_security_group_id = module.master-security-group.this_security_group_id
    },
    {
      from_port                = 10250
      to_port                  = 10250
      protocol                 = "tcp"
      description              = "kubernetes secure kubelet port"
      source_security_group_id = module.worker-security-group.this_security_group_id
    },
    {
      from_port                = 4789
      to_port                  = 4789
      protocol                 = "udp"
      description              = "Vxlan packets"
      source_security_group_id = module.master-security-group.this_security_group_id
    },
    {
      from_port                = 4789
      to_port                  = 4789
      protocol                 = "udp"
      description              = "Vxlan packets"
      source_security_group_id = module.worker-security-group.this_security_group_id
    }
  ]

}
data "aws_vpc" "selected" {
  tags = {
    Name = var.vpc
  }
}
data "aws_subnet_ids" "selected" {
  vpc_id = data.aws_vpc.selected.id
  tags = {
    Name  = var.subnet_filter
  }
}
data "aws_instances" "masters" {
    filter {
      name = "tag:Name"
      values = ["master-${var.clusterid}-*","bootstrap-${var.clusterid}"]
    }
    filter {
      name = "tag:Environment"
      values = [var.tag_environment]
    }
}

resource "aws_alb" "okd-api" {
  name               = var.nlb_api_name
  load_balancer_type = var.load_balancer_type
  internal           = var.internal
  subnets            = data.aws_subnet_ids.selected.ids

  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_deletion_protection       = var.enable_deletion_protection

  tags = {
    Name              = var.tag_name
    Environment       = var.tag_environment
    Project           = var.tag_project
    Role              = var.tag_role
  }

}

resource "aws_alb_target_group" "okd-api-6443" {
  name        = "api-${var.nlb_target_group_name}-6443"
  vpc_id      = data.aws_vpc.selected.id
  port        = "6443"
  protocol    = var.target_group_protocol
  target_type = var.target_group_type

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 10
    protocol            = "HTTPS"
    path                = "/readyz"
    port                = "6443"
    matcher             = "200-399"
  }
 
  stickiness {
    type    = "source_ip"
    enabled = false
  }

  tags = {}

}
resource "aws_alb_listener" "okd-api-6443" {
  load_balancer_arn = aws_alb.okd-api.arn
  port              = "6443"
  protocol          = var.listener_protocol

  default_action {
    type              = var.listener_type
    target_group_arn  = aws_alb_target_group.okd-api-6443.arn
  }
}
resource "aws_alb_target_group" "okd-api-22623" {
  name        = "ai-${var.nlb_target_group_name}-22623"
  vpc_id      = data.aws_vpc.selected.id
  port        = "22623"
  protocol    = var.target_group_protocol
  target_type = var.target_group_type

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 10
    protocol            = "HTTPS"
    port                = "22623"
    path                = "/healthz"
    matcher             = "200-399"
  }
  
  stickiness {
    type    = "source_ip"
    enabled = false
  }

  tags = {}

}
resource "aws_alb_listener" "okd-api-22623" {
  load_balancer_arn = aws_alb.okd-api.arn
  port              = "22623"
  protocol          = var.listener_protocol

  default_action {
    type              = var.listener_type
    target_group_arn  = aws_alb_target_group.okd-api-22623.arn
  }
}

resource "aws_alb_target_group_attachment" "okd-api-6443" {
  count            = length(data.aws_instances.masters.private_ips)
  target_group_arn = aws_alb_target_group.okd-api-6443.arn
  target_id        = data.aws_instances.masters.private_ips[count.index]
  port             = "6443"
}
resource "aws_alb_target_group_attachment" "okd-api-22623" {
  count            = length(data.aws_instances.masters.private_ips)
  target_group_arn = aws_alb_target_group.okd-api-22623.arn
  target_id        = data.aws_instances.masters.private_ips[count.index]
  port             = "22623"
}


data "aws_alb" "openshift-api-ext" {
  name =  var.nlb_api_name
  depends_on = [aws_alb.okd-api]
}
#######################################
# Wildcard internal and external routes
#######################################
resource "aws_route53_record" "router-ext" {
  zone_id = var.zone_id
  name    = "api.${var.cluster_name}"
  type    = "CNAME"
  ttl     = "60"
  records = [data.aws_alb.openshift-api-ext.dns_name]
  depends_on = [aws_alb.okd-api]
}
resource "aws_route53_record" "router-int" {
  zone_id = var.zone_id
  name    = "api-int.${var.cluster_name}"
  type    = "CNAME"
  ttl     = "60"
  records = [data.aws_alb.openshift-api-ext.dns_name]
  depends_on = [aws_alb.okd-api]
}

output "master_ips" {
  value = data.aws_instances.masters.private_ips
}


resource "aws_lb" "alb" {
  for_each = var.albs

  name               = each.value.name
  internal           = each.value.internal
  load_balancer_type = each.value.load_balancer_type

  security_groups = (
    each.value.load_balancer_type == "application"
    ? each.value.security_groups
    : null
  )

  subnets = each.value.subnets

  enable_deletion_protection = each.value.enable_deletion_protection
  drop_invalid_header_fields = (
    each.value.load_balancer_type == "application"
    ? each.value.drop_invalid_header_fields
    : null
  )

  idle_timeout    = each.value.idle_timeout
  ip_address_type = each.value.ip_address_type

  tags = each.value.tags
}

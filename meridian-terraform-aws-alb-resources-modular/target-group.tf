resource "aws_lb_target_group" "target_group" {
  for_each = {
    for tg in var.target_group_config :
    tg.name => tg
  }

  name        = each.value.name
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = each.value.vpc_id
  target_type = each.value.target_type

  deregistration_delay = each.value.deregistration_delay
  slow_start           = each.value.slow_start

  health_check {
    enabled             = each.value.health_check.enabled
    protocol            = each.value.health_check.protocol
    port                = each.value.health_check.port
    path                = each.value.health_check.path
    matcher             = each.value.health_check.matcher
    interval            = each.value.health_check.interval
    timeout             = each.value.health_check.timeout
    healthy_threshold   = each.value.health_check.healthy_threshold
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
  }

  dynamic "stickiness" {
    for_each = each.value.stickiness.enabled ? [1] : []

    content {
      enabled         = true
      type            = each.value.stickiness.type
      cookie_duration = each.value.stickiness.cookie_duration
    }
  }

  tags = each.value.tags
}

resource "aws_lb_listener_rule" "listener_rule" {
  for_each = var.rules

  listener_arn = (
    each.value.listener_arn != null
    ? each.value.listener_arn
    : aws_lb_listener.listener[coalesce(each.value.listener_key, each.key)].arn
  )
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = (
      each.value.target_group_arn != null
      ? each.value.target_group_arn
      : aws_lb_target_group.target_group[coalesce(each.value.target_group_key, each.key)].arn
    )
  }

  dynamic "condition" {
    for_each = each.value.path_patterns != null ? [1] : []

    content {
      path_pattern {
        values = each.value.path_patterns
      }
    }
  }

  dynamic "condition" {
    for_each = each.value.host_headers != null ? [1] : []

    content {
      host_header {
        values = each.value.host_headers
      }
    }
  }

  dynamic "condition" {
    for_each = each.value.source_ips != null ? [1] : []

    content {
      source_ip {
        values = each.value.source_ips
      }
    }
  }

  tags = each.value.tags
}

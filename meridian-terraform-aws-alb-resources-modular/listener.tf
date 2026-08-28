resource "aws_lb_listener" "listener" {
  for_each = var.listeners

  load_balancer_arn = (
    each.value.load_balancer_arn != null
    ? each.value.load_balancer_arn
    : aws_lb.alb[coalesce(each.value.load_balancer_key, each.key)].arn
  )
  port              = each.value.port
  protocol          = each.value.protocol

  ssl_policy      = each.value.ssl_policy
  certificate_arn = each.value.certificate_arn

  default_action {
    type = each.value.default_action_type

    dynamic "forward" {
      for_each = each.value.default_action_type == "forward" ? [1] : []

      content {
        target_group {
          arn = (
            each.value.target_group_arn != null
            ? each.value.target_group_arn
            : aws_lb_target_group.target_group[coalesce(each.value.target_group_key, each.key)].arn
          )
        }
      }
    }

    dynamic "fixed_response" {
      for_each = each.value.default_action_type == "fixed-response" ? [1] : []

      content {
        content_type = each.value.fixed_response_content_type
        message_body = each.value.fixed_response_message_body
        status_code  = each.value.fixed_response_status_code
      }
    }
  }

  tags = each.value.tags
}

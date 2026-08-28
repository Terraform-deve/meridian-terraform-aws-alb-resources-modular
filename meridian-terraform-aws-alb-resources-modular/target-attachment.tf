resource "aws_lb_target_group_attachment" "target_attachment" {
  for_each = {
    for target in var.target_attachments :
    target.name => target
  }

  target_group_arn = (
    each.value.target_group_arn != null
    ? each.value.target_group_arn
    : aws_lb_target_group.target_group[each.value.target_group_key].arn
  )
  target_id         = each.value.target_id
  port              = each.value.port
  availability_zone = each.value.availability_zone
}

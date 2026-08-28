output "alb_arns" {
  description = "Map of load balancer keys to ARNs."

  value = {
    for key, alb in aws_lb.alb :
    key => alb.arn
  }
}

output "alb_dns_names" {
  description = "Map of load balancer keys to DNS names."

  value = {
    for key, alb in aws_lb.alb :
    key => alb.dns_name
  }
}

output "alb_zone_ids" {
  description = "Map of load balancer keys to Route 53 zone IDs."

  value = {
    for key, alb in aws_lb.alb :
    key => alb.zone_id
  }
}

output "tg_arns" {
  description = "Map of target group names to ARNs."

  value = {
    for key, tg in aws_lb_target_group.target_group :
    key => tg.arn
  }
}

output "tg_names" {
  description = "Map of target group names to names."

  value = {
    for key, tg in aws_lb_target_group.target_group :
    key => tg.name
  }
}

output "tg_arn_suffixes" {
  description = "Map of target group names to ARN suffixes."

  value = {
    for key, tg in aws_lb_target_group.target_group :
    key => tg.arn_suffix
  }
}

output "listener_arns" {
  description = "Map of listener keys to ARNs."

  value = {
    for key, listener in aws_lb_listener.listener :
    key => listener.arn
  }
}

output "listener_ids" {
  description = "Map of listener keys to IDs."

  value = {
    for key, listener in aws_lb_listener.listener :
    key => listener.id
  }
}

output "rule_arns" {
  description = "Map of rule keys to rule ARNs."

  value = {
    for key, rule in aws_lb_listener_rule.listener_rule :
    key => rule.arn
  }
}

output "rule_ids" {
  description = "Map of rule keys to rule IDs."

  value = {
    for key, rule in aws_lb_listener_rule.listener_rule :
    key => rule.id
  }
}

output "target_attachment_ids" {
  description = "Map of attachment names to IDs."

  value = {
    for key, attachment in aws_lb_target_group_attachment.target_attachment :
    key => attachment.id
  }
}

variable "albs" {
  description = "Map of load balancers to create."

  type = map(object({
    name                       = string
    internal                   = bool
    load_balancer_type         = optional(string, "application")
    security_groups            = optional(list(string), [])
    subnets                    = list(string)
    enable_deletion_protection = optional(bool, true)
    drop_invalid_header_fields = optional(bool, true)
    idle_timeout               = optional(number, 60)
    ip_address_type            = optional(string, "ipv4")
    tags                       = optional(map(string), {})
  }))

  default = {}

  validation {
    condition = alltrue([
      for alb in var.albs :
      contains(["application", "network", "gateway"], alb.load_balancer_type)
    ])
    error_message = "load_balancer_type must be application, network, or gateway."
  }
}

variable "target_group" {
  description = "List of target group configurations."

  type = list(object({
    name        = string
    port        = number
    protocol    = string
    vpc_id      = string
    target_type = optional(string, "instance")

    deregistration_delay = optional(number, 300)
    slow_start           = optional(number, 0)

    health_check = optional(object({
      enabled             = optional(bool, true)
      protocol            = optional(string, "HTTP")
      port                = optional(string, "traffic-port")
      path                = optional(string, "/")
      matcher             = optional(string, "200")
      interval            = optional(number, 30)
      timeout             = optional(number, 5)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
    }), {})

    stickiness = optional(object({
      enabled         = optional(bool, false)
      type            = optional(string, "lb_cookie")
      cookie_duration = optional(number, 86400)
    }), {})

    tags = optional(map(string), {})
  }))

  default = []

  validation {
    condition = alltrue([
      for tg in var.target_group :
      contains(["instance", "ip", "lambda", "alb"], tg.target_type)
    ])
    error_message = "target_type must be instance, ip, lambda, or alb."
  }
}

variable "listeners" {
  description = "Listener configurations. Use load_balancer_key to automatically reference an ALB created by this project, or load_balancer_arn for an external ALB."

  type = map(object({
    load_balancer_key = optional(string)
    load_balancer_arn = optional(string)
    port              = number
    protocol          = string

    ssl_policy      = optional(string)
    certificate_arn = optional(string)

    default_action_type = optional(string, "fixed-response")
    target_group_key    = optional(string)
    target_group_arn    = optional(string)

    fixed_response_content_type = optional(string, "text/plain")
    fixed_response_message_body = optional(string, "No matching rule")
    fixed_response_status_code  = optional(string, "404")

    tags = optional(map(string), {})
  }))

  default = {}

  validation {
    condition = alltrue([
      for listener in var.listeners :
      contains(["HTTP", "HTTPS"], listener.protocol)
    ])
    error_message = "protocol must be HTTP or HTTPS."
  }

  validation {
    condition = alltrue([
      for listener in var.listeners :
      listener.protocol == "HTTP" || (
        listener.certificate_arn != null &&
        listener.ssl_policy != null
      )
    ])
    error_message = "HTTPS listeners require certificate_arn and ssl_policy."
  }

  validation {
    condition = alltrue([
      for listener in var.listeners :
      contains(["forward", "fixed-response"], listener.default_action_type)
    ])
    error_message = "default_action_type must be forward or fixed-response."
  }

}

variable "rules" {
  description = "Listener rule configurations. Uses keys to automatically reference listeners and target groups created by this project, or ARNs for external resources."

  type = map(object({
    listener_key     = optional(string)
    listener_arn     = optional(string)

    priority         = number

    target_group_key = optional(string)
    target_group_arn = optional(string)

    # Normal matching
    path_patterns = optional(list(string))
    host_headers  = optional(list(string))
    source_ips    = optional(list(string))

    # Regex matching
    path_regex         = optional(list(string))
    host_header_regex  = optional(list(string))

    tags = optional(map(string), {})
  }))

  default = {}

  validation {
    condition = alltrue([
      for rule in var.rules :
      rule.path_patterns != null ||
      rule.path_regex != null ||
      rule.host_headers != null ||
      rule.host_header_regex != null ||
      rule.source_ips != null
    ])

    error_message = "Every rule must have at least one condition."
  }

  validation {
    condition = alltrue([
      for rule in var.rules :
      (rule.path_patterns == null || length(rule.path_patterns) > 0) &&
      (rule.path_regex == null || length(rule.path_regex) > 0) &&
      (rule.host_headers == null || length(rule.host_headers) > 0) &&
      (rule.host_header_regex == null || length(rule.host_header_regex) > 0) &&
      (rule.source_ips == null || length(rule.source_ips) > 0)
    ])

    error_message = "Condition lists cannot be empty."
  }

  validation {
    condition = alltrue([
      for rule in var.rules :
      rule.priority >= 1 && rule.priority <= 50000
    ])

    error_message = "Listener rule priority must be between 1 and 50000."
  }
}


variable "target_attachments" {
  description = "EC2 instance IDs or IP addresses registered against target groups. Use target_group_key for a target group created by this project, or target_group_arn for an external target group."

  type = list(object({
    name              = string
    target_group_key  = optional(string)
    target_group_arn  = optional(string)
    target_id         = string
    port              = optional(number)
    availability_zone = optional(string)
  }))

  default = []

  validation {
    condition = alltrue([
      for target in var.target_attachments :
      target.target_group_key != null ||
      target.target_group_arn != null
    ])
    error_message = "Each target attachment requires target_group_key or target_group_arn."
  }
}

# meridian-terraform-aws-alb-resources

Terraform configuration for AWS Application Load Balancer resources in a flat root-module structure.

## Project Structure

```text
meridian-terraform-aws-alb-resources/
|-- alb.tf
|-- listener.tf
|-- listener-rule.tf
|-- target-attachment.tf
|-- target-group.tf
|-- outputs.tf
|-- variables.tf
|-- README.md
```

## Files

| File | Purpose |
| --- | --- |
| `alb.tf` | Creates Application, Network, or Gateway Load Balancers. |
| `target-group.tf` | Creates load balancer target groups. |
| `listener.tf` | Creates load balancer listeners. |
| `listener-rule.tf` | Creates listener rules that forward to target groups. |
| `target-attachment.tf` | Registers targets with target groups. |
| `variables.tf` | Defines all inputs used by the root module. |
| `outputs.tf` | Exposes ALB, listener, rule, target group, and attachment outputs. |

## Usage

Provide values with `terraform.tfvars`, `*.auto.tfvars`, CI/CD variables, or `TF_VAR_*` environment variables.

```bash
terraform init
terraform fmt
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## Example

```hcl
albs = {
  app = {
    name               = "example-app-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = ["sg-0123456789abcdef0"]
    subnets            = ["subnet-0123456789abcdef0", "subnet-abcdef01234567890"]

    tags = {
      Environment = "dev"
      Project     = "meridian"
    }
  }
}

target_group_config = [
  {
    name     = "example-app-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = "vpc-0123456789abcdef0"

    health_check = {
      path    = "/health"
      matcher = "200"
    }

    tags = {
      Environment = "dev"
      Project     = "meridian"
    }
  }
]

listeners = {
  http = {
    load_balancer_arn   = "arn:aws:elasticloadbalancing:region:account-id:loadbalancer/app/example-app-alb/id"
    port                = 80
    protocol            = "HTTP"
    default_action_type = "fixed-response"
  }
}

rules = {
  app = {
    listener_arn     = "arn:aws:elasticloadbalancing:region:account-id:listener/app/example-app-alb/id/listener-id"
    priority         = 100
    target_group_arn = "arn:aws:elasticloadbalancing:region:account-id:targetgroup/example-app-tg/id"
    path_patterns    = ["/app/*"]
  }
}

target_attachments = [
  {
    name             = "app-instance-1"
    target_group_arn = "arn:aws:elasticloadbalancing:region:account-id:targetgroup/example-app-tg/id"
    target_id        = "i-0123456789abcdef0"
    port             = 80
  }
]
```

## Notes

- All resource maps and lists default to empty, so you can create only the resource types you need.
- Listener and rule inputs use ARNs. Use outputs from a previous apply, remote state, or explicit values from your environment.
- Do not commit `terraform.tfvars` if it contains environment-specific or sensitive values.

# meridian-terraform-aws-alb-resources

Modular Terraform implementation for AWS Application Load Balancers.

## Design

The repository is intentionally split into two layers:

```text
modules/
    Reusable Terraform modules

alb/
targetgroup/
listener/
listener-rule/
target-attachment/
    Independent Terraform root configurations
```

Each resource type has its own Terraform state because each directory is a separate Terraform root.

There are no hard-coded AWS resource IDs in the reusable modules.

Prerequisite resource IDs/ARNs are passed as variables.

## Independence

You can run:

```bash
cd alb
terraform init
terraform apply
```

to create only the ALB.

Or:

```bash
cd targetgroup
terraform init
terraform apply
```

to create only target groups.

The listener configuration accepts an existing ALB ARN. It does not create the ALB.

The listener-rule configuration accepts existing listener and target-group ARNs. It does not create either resource.

The target-attachment configuration accepts an existing target-group ARN. It does not create the target group.

## Project structure

```text
meridian-terraform-aws-alb-resources/
│
├── modules/
│   ├── alb/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── targetgroup/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── listener/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── listener-rule/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── target-attachment/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├──README.md
```

## No hard-coded values

The environment root files contain variable declarations and module calls. Values should be supplied through:

- `terraform.tfvars`
- `*.auto.tfvars`
- CI/CD variables
- environment variables such as `TF_VAR_aws_region`

For production, do not commit `terraform.tfvars` when it contains environment-specific or sensitive values.

## Example commands

### ALB

```bash
cd alb
terraform init
terraform fmt
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### Target group

```bash
cd targetgroup
terraform init
terraform fmt
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### Listener

```bash
cd listener
terraform init
terraform fmt
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### Listener rule

```bash
cd listener-rule
terraform init
terraform fmt
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### Target attachment

```bash
cd target-attachment
terraform init
terraform fmt
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## Terraform state

Because the five root directories are independent, configure a separate backend/state for each root in your actual environment.

Do not connect the roots with Terraform module references if independent lifecycle/state is required.

## Resource relationships

```text
ALB
  │
  │ existing ALB ARN
  ▼
Listener

Target Group
  │
  ├── existing TG ARN ──> Listener Rule
  │
  └── existing TG ARN ──> Target Attachment
```

The relationships are passed as input values instead of Terraform state dependencies.

## Important AWS note

Independence here means independent Terraform management. AWS still requires valid relationships:

- a listener must reference an existing load balancer
- a listener rule must reference an existing listener and target group
- a target attachment must reference an existing target group

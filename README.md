# Qovery GitOps Example

This repository contains an example of how to deploy an app and database using Qovery in a GitOps way.

## Files

- `main.tf` - Terraform file to create a Qovery environment
- `variables.tf` - Terraform variables
- `.github/workflows/terraform-plan.yml` - GitHub Actions workflow to plan Terraform changes on new Pull Request
- `.github/workflows/terraform-apply.yml` - GitHub Actions workflow to apply Terraform changes on merged Pull Request and main branch push

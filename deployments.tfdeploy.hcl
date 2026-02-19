deployment_group "production_cells" {
  auto_approve_checks = [
    deployment_auto_approve.no_destructive_changes
  ]
}

deployment_auto_approve "no_destructive_changes" {
  check {
    condition = context.plan.changes.remove == 0
    reason    = "Mudanças destrutivas requerem aprovação rigorosa."
  }
}

# Deployments na AWS
deployment "aws_sa_east_1_supercell" {
  inputs = { target_region = "sa-east-1", provider_type = "aws" }
  deployment_group = deployment_group.production_cells
}

deployment "aws_us_east_1_supercell" {
  inputs = { target_region = "us-east-1", provider_type = "aws" }
  deployment_group = deployment_group.production_cells
}

# Deployments na Azure
deployment "azure_brazilsouth_supercell" {
  inputs = { target_region = "brazilsouth", provider_type = "azure" }
  deployment_group = deployment_group.production_cells
}

deployment "azure_eastus_supercell" {
  inputs = { target_region = "eastus", provider_type = "azure" }
  deployment_group = deployment_group.production_cells
}
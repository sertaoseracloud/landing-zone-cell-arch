deployment_group "production_cells" {}

deployment "aws_sa_east_1" {
  inputs = { target_region = "sa-east-1", provider_type = "aws" }
  deployment_group = deployment_group.production_cells
}

deployment "aws_us_east_1" {
  inputs = { target_region = "us-east-1", provider_type = "aws" }
  deployment_group = deployment_group.production_cells
}

deployment "azure_brazilsouth" {
  inputs = { target_region = "brazilsouth", provider_type = "azure" }
  deployment_group = deployment_group.production_cells
}

deployment "azure_eastus" {
  inputs = { target_region = "eastus", provider_type = "azure" }
  deployment_group = deployment_group.production_cells
}

deployment "global_cloudflare_routing" {
  inputs = { target_region = "global", provider_type = "cloudflare" }
}
locals {
  is_aws   = var.provider_type == "aws"
  is_azure = var.provider_type == "azure"
}
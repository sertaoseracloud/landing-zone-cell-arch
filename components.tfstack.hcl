variable "provider_type" { type = string }
variable "target_region" { type = string }

component "orchestrator" {
  source = "./components/orchestrator"
  inputs = {
    provider_type = var.provider_type
    target_region = var.target_region
  }
}
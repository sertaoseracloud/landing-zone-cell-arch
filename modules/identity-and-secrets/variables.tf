variable "provider_type" { type = string }
variable "cluster_name" { type = string }
variable "namespace" { type = string default = "application-ns" }
variable "service_account_name" { type = string default = "app-sa" }

variable "aws_eks_cluster_name" { type = string default = null }
variable "azure_resource_group" { type = string default = null }
variable "azure_location" { type = string default = null }
variable "azure_aks_issuer_url" { type = string default = null }
variable "azure_key_vault_uri" { type = string default = "https://default-kv.vault.azure.net/" }

variable "vault_mount_path" { type = string default = "secret" }
variable "vault_secret_name" { type = string default = "app-credentials" }
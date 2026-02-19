variable "provider_type" { type = string }
variable "cluster_name" { type = string }
variable "aws_eks_cluster_name" { type = string default = null }
variable "azure_resource_group" { type = string default = null }
variable "azure_location" { type = string default = null }
variable "azure_aks_issuer_url" { type = string default = null }
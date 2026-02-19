locals {
  raw_config = yamldecode(file("${path.root}/../../infrastructure.yaml"))
  cells = {
    for k, v in local.raw_config.environments :
    k => v if v.region == var.target_region && v.provider == var.provider_type
  }
}

# --- 1. Computação Base (EKS/AKS) ---
module "aws_cells" {
  source            = "../../modules/aws-eks-cell"
  for_each          = var.provider_type == "aws"? local.cells : {}
  availability_zone = each.value.availability_zone
  region            = each.value.region
}

module "azure_cells" {
  source            = "../../modules/azure-aks-cell"
  for_each          = var.provider_type == "azure"? local.cells : {}
  region            = each.value.region
  availability_zone = each.value.availability_zone
}

# --- 2. API Gateways ---
module "api_gateway" {
  source               = "../../modules/api-gateway"
  for_each             = var.provider_type!= "cloudflare"? local.cells : {}
  
  provider_type        = var.provider_type
  cluster_name         = var.provider_type == "aws"? module.aws_cells[each.key].cluster_name : module.azure_cells[each.key].cluster_name
  
  # Variáveis Específicas
  subnet_ids           = var.provider_type == "aws"? module.aws_cells[each.key].subnet_ids : module.azure_cells[each.key].subnet_ids
  internal_lb_arn      = var.provider_type == "aws"? module.aws_cells[each.key].internal_nlb_arn : module.azure_cells[each.key].internal_lb_ip
  azure_resource_group = var.provider_type == "azure"? module.azure_cells[each.key].resource_group_name : null
  azure_location       = var.provider_type == "azure"? each.value.region : null
}

# --- 3. Identidade e Segredos ---
module "identity_layer" {
  source               = "../../modules/identity-and-secrets"
  for_each             = var.provider_type!= "cloudflare"? local.cells : {}
  
  provider_type        = var.provider_type
  cluster_name         = var.provider_type == "aws"? module.aws_cells[each.key].cluster_name : module.azure_cells[each.key].cluster_name
  
  aws_eks_cluster_name = var.provider_type == "aws"? module.aws_cells[each.key].cluster_name : null
  azure_resource_group = var.provider_type == "azure"? module.azure_cells[each.key].resource_group_name : null
  azure_location       = var.provider_type == "azure"? each.value.region : null
  azure_aks_issuer_url = var.provider_type == "azure"? module.azure_cells[each.key].oidc_issuer_url : null
}

# --- 4. Conectividade BGP Multi-Cloud ---
module "interconnect_us" {
  source       = "../../modules/multi-cloud-connectivity"
  count        = var.target_region == "us-east-1" |

| var.target_region == "eastus"? 1 : 0
  aws_region   = "us-east-1"
  azure_region = "eastus"
}

module "interconnect_br" {
  source       = "../../modules/multi-cloud-connectivity"
  count        = var.target_region == "sa-east-1" |

| var.target_region == "brazilsouth"? 1 : 0
  aws_region   = "sa-east-1"
  azure_region = "brazilsouth"
}

# --- 5. Global Load Balancer (Cloudflare) ---
module "global_routing" {
  source   = "../../modules/global-load-balancer"
  count    = var.provider_type == "cloudflare"? 1 : 0
  
  # Na prática real de Stacks, estas variáveis viriam de outputs via data sources cross-stack
  aws_apigw_sa  = "api-sa.aws.internal" 
  azure_apim_sa = "api-sa.azure.internal"
  aws_apigw_us  = "api-us.aws.internal"
  azure_apim_us = "api-us.azure.internal"
}
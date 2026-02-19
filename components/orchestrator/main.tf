locals {
  raw_config = yamldecode(file("${path.root}/../../infrastructure.yaml"))
  
  cells = {
    for k, v in local.raw_config.environments :
    k => v if v.region == var.target_region && v.provider == var.provider_type
  }
}

module "aws_cells" {
  source   = "../../modules/aws-eks-cell"
  for_each = var.provider_type == "aws"? local.cells : {}
  
  region            = each.value.region
  availability_zone = each.value.availability_zone
  instance_type     = each.value.compute_size == "intensive"? "c5.2xlarge" : "m5.large"
}

module "azure_cells" {
  source   = "../../modules/azure-aks-cell"
  for_each = var.provider_type == "azure"? local.cells : {}
  
  region            = each.value.region
  availability_zone = each.value.availability_zone
  vm_size           = each.value.compute_size == "intensive"? "Standard_D8s_v5" : "Standard_D4s_v5"
}

# Malha de Interconexão (Aplicada apenas quando provisionando as nuvens nas regiões combinadas)
module "multi_cloud_interconnect_us" {
  source = "../../modules/multi-cloud-connectivity"
  count  = var.target_region == "us-east-1" |

| var.target_region == "eastus"? 1 : 0
  
  aws_region   = "us-east-1"
  azure_region = "eastus"
}

module "multi_cloud_interconnect_br" {
  source = "../../modules/multi-cloud-connectivity"
  count  = var.target_region == "sa-east-1" |

| var.target_region == "brazilsouth"? 1 : 0
  
  aws_region   = "sa-east-1"
  azure_region = "brazilsouth"
}
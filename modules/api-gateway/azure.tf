resource "azurerm_api_management" "cell_apim" {
  count               = local.is_azure? 1 : 0
  name                = "apim-${var.cluster_name}"
  location            = var.azure_location
  resource_group_name = var.azure_resource_group
  publisher_name      = "Corp"
  publisher_email     = "admin@corp.com"
  sku_name            = "Developer_1"

  virtual_network_type = "External"
  virtual_network_configuration {
    subnet_id = var.subnet_ids
  }
}

resource "azurerm_api_management_api" "aks_api" {
  count               = local.is_azure? 1 : 0
  name                = "aks-backend"
  resource_group_name = var.azure_resource_group
  api_management_name = azurerm_api_management.cell_apim.name
  revision            = "1"
  display_name        = "AKS Backend"
  path                = ""
  protocols           = ["https"]
  service_url         = "http://${var.internal_lb_arn}" 
}
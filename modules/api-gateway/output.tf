output "api_endpoint_aws" {
  value = local.is_aws? aws_apigatewayv2_api.cell_api.api_endpoint : null
}

output "api_endpoint_azure" {
  value = local.is_azure? azurerm_api_management.cell_apim.gateway_url : null
}
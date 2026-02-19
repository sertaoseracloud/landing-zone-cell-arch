resource "azurerm_user_assigned_identity" "workload_identity" {
  count               = local.is_azure? 1 : 0
  name                = "${var.cluster_name}-workload-id"
  resource_group_name = var.azure_resource_group
  location            = var.azure_location
}

resource "azurerm_federated_identity_credential" "aks_federation" {
  count               = local.is_azure? 1 : 0
  name                = "${var.cluster_name}-fed-cred"
  resource_group_name = var.azure_resource_group
  parent_id           = azurerm_user_assigned_identity.workload_identity.id
  audience            =
  issuer              = var.azure_aks_issuer_url
  subject             = "system:serviceaccount:application-ns:app-sa"
}
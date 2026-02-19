resource "azurerm_resource_group" "cell_rg" {
  name     = "rg-cell-${var.region}-${var.availability_zone}"
  location = var.region
}

resource "azurerm_virtual_network" "cell_vnet" {
  name                = "vnet-cell-${var.region}"
  location            = azurerm_resource_group.cell_rg.location
  resource_group_name = azurerm_resource_group.cell_rg.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "cell_subnet" {
  name                 = "snet-cell-${var.availability_zone}"
  resource_group_name  = azurerm_resource_group.cell_rg.name
  virtual_network_name = azurerm_virtual_network.cell_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_kubernetes_cluster" "cell_cluster" {
  name                = "aks-cell-${var.region}-${var.availability_zone}"
  location            = azurerm_resource_group.cell_rg.location
  resource_group_name = azurerm_resource_group.cell_rg.name
  dns_prefix          = "akscell"

  default_node_pool {
    name           = "default"
    node_count     = 3
    vm_size        = var.vm_size
    zones          = [var.availability_zone]
    vnet_subnet_id = azurerm_subnet.cell_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }
}
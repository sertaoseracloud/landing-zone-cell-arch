resource "aws_ec2_transit_gateway" "tgw" {
  amazon_side_asn = 64512
  tags = { Name = "global-tgw-${var.aws_region}" }
}

resource "azurerm_resource_group" "net_rg" {
  name     = "rg-global-network-${var.azure_region}"
  location = var.azure_region
}

resource "azurerm_virtual_wan" "vwan" {
  name                = "vwan-global-${var.azure_region}"
  resource_group_name = azurerm_resource_group.net_rg.name
  location            = azurerm_resource_group.net_rg.location
}

resource "azurerm_virtual_hub" "vhub" {
  name                = "vhub-${var.azure_region}"
  resource_group_name = azurerm_resource_group.net_rg.name
  location            = azurerm_resource_group.net_rg.location
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  address_prefix      = "10.2.0.0/16"
}

resource "azurerm_vpn_gateway" "vpngw" {
  name                = "vpngw-${var.azure_region}"
  location            = azurerm_resource_group.net_rg.location
  resource_group_name = azurerm_resource_group.net_rg.name
  virtual_hub_id      = azurerm_virtual_hub.vhub.id
  bgp_settings {
    asn         = 65000
    peer_weight = 0
  }
}

resource "aws_customer_gateway" "azure_cgw" {
  bgp_asn    = 65000
  ip_address = azurerm_vpn_gateway.vpngw.bgp_settings.peering_addresses.default_addresses
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "azure_tunnel" {
  customer_gateway_id = aws_customer_gateway.azure_cgw.id
  transit_gateway_id  = aws_ec2_transit_gateway.tgw.id
  type                = "ipsec.1"
}

resource "azurerm_vpn_site" "aws_site" {
  name                = "aws-tgw-site-${var.aws_region}"
  location            = azurerm_resource_group.net_rg.location
  resource_group_name = azurerm_resource_group.net_rg.name
  virtual_wan_id      = azurerm_virtual_wan.vwan.id

  link {
    name       = "aws-tunnel-1"
    ip_address = aws_vpn_connection.azure_tunnel.tunnel1_address
    bgp {
      asn             = 64512
      peering_address = aws_vpn_connection.azure_tunnel.tunnel1_cgw_inside_address
    }
  }
}
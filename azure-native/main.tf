resource "azurerm_resource_group" "vwan_rg" {
  name     = var.rg_name
  location = var.region
}

resource "azurerm_virtual_wan" "orsted_vwan" {
  name                = var.vwan_name
  resource_group_name = azurerm_resource_group.vwan_rg.name
  location            = azurerm_resource_group.vwan_rg.location
}

resource "azurerm_virtual_hub" "orsted_vwan_hub" {
  name                = var.vwan_hub_name
  resource_group_name = azurerm_resource_group.vwan_rg.name
  location            = azurerm_resource_group.vwan_rg.location
  virtual_wan_id      = azurerm_virtual_wan.orsted_vwan.id
  address_prefix      = var.vwan_hub_prefix
}

resource "azurerm_virtual_hub_connection" "cnx_to_avx_transit" {
  name                      = "cnx_to_avx_transit"
  virtual_hub_id            = azurerm_virtual_hub.orsted_vwan_hub.id
  remote_virtual_network_id = var.avx_transit_vnet
}

resource "azurerm_virtual_hub_connection" "cnx_to_vnet_1" {
  name                      = "cnx_to_vnet_1"
  virtual_hub_id            = azurerm_virtual_hub.orsted_vwan_hub.id
  remote_virtual_network_id = var.vnet_1_id
}

resource "azurerm_virtual_hub_connection" "cnx_to_vnet_2" {
  name                      = "cnx_to_vnet_2"
  virtual_hub_id            = azurerm_virtual_hub.orsted_vwan_hub.id
  remote_virtual_network_id = var.vnet_2_id
}

resource "azurerm_virtual_hub_bgp_connection" "peer_avx_prim" {
  name           = "peer_avx_prim"
  virtual_hub_id = azurerm_virtual_hub.orsted_vwan_hub.id
  peer_asn       = var.avx_transit_gateway_asn
  peer_ip        = var.avx_prim_gw_ip
  virtual_network_connection_id = azurerm_virtual_hub_connection.cnx_to_avx_transit.id
}


resource "azurerm_virtual_hub_bgp_connection" "peer_avx_ha" {
  name           = "peer_avx_ha"
  virtual_hub_id = azurerm_virtual_hub.orsted_vwan_hub.id
  peer_asn       = var.avx_transit_gateway_asn
  peer_ip        = var.avx_ha_gw_ip
  virtual_network_connection_id = azurerm_virtual_hub_connection.cnx_to_avx_transit.id
}


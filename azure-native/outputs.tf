data "azurerm_virtual_hub" "example" {
  name                = azurerm_virtual_hub.orsted_vwan_hub.name
  resource_group_name = azurerm_resource_group.vwan_rg.name
}

output "virtual_hub_ips" {
  value = data.azurerm_virtual_hub.example.virtual_router_ips
}


# output "public_ip_spk" {
#   value = azurerm_public_ip.public_ip_spoke_vm.ip_address
# }

# output "public_ip_vwan_spk" {
#   value = azurerm_public_ip.public_ip.ip_address
# }

# output "sdwan1_vnet_name" {
#   value = azurerm_virtual_network.sdwan_vnet.name
# }

# output "sdwan1_rg" {
#   value = azurerm_virtual_network.sdwan_vnet.resource_group_name
# }
output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

data "azurerm_public_ip" "public_ip" {
  name                = azurerm_public_ip.public_ip_spoke_vm.name
  resource_group_name = azurerm_resource_group.example.name
}

output "public_ip_address" {
  value = data.azurerm_public_ip.public_ip.ip_address
}
data "azurerm_virtual_network" "example" {
  name                = module.azure_transit.vpc.id
  resource_group_name = module.azure_transit.vpc.resource_group
  depends_on = [ module.azure_transit ]
}

data "azurerm_subscription" "current" {}

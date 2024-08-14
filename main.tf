module "azure_vnets" {
  source   = "./vnet_module"
  for_each = local.vnet_details

  vnet_name     = each.key
  rg_name       = each.value.rg_name
  location      = each.value.location
  pub_subnets   = each.value.pub_subnets
  priv_subnets  = each.value.priv_subnets
  address_space = each.value.address_space
}

module "azure_transit" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.5.3"

  cloud                    = "azure"
  region                   = var.region
  cidr                     = var.transit_cidr
  account                  = var.ctrl_azure_acc
  local_as_number          = var.avx_transit_gateway_asn
  insane_mode              = true
  instance_size            = "Standard_D5_v2"
  bgp_lan_interfaces_count = 2
  enable_bgp_over_lan      = true
  enable_transit_firenet   = true
  depends_on = [ module.azure_vnets ]
}

module "azure_native" {
  source                  = "./azure-native"
  rg_name                 = var.rg_name
  region                  = var.region
  vwan_name               = var.vwan_name
  vwan_hub_name           = var.vwan_hub_name
  vwan_hub_prefix         = var.vwan_hub_prefix
  avx_transit_gateway_asn = var.avx_transit_gateway_asn
  avx_prim_gw_ip          = module.azure_transit.transit_gateway.bgp_lan_ip_list[0]
  avx_ha_gw_ip            = module.azure_transit.transit_gateway.ha_bgp_lan_ip_list[0]
  avx_transit_vnet        = module.azure_transit.vpc.azure_vnet_resource_id
  avx_transit_vnet_rg     = module.azure_transit.vpc.resource_group
  avx_transit_vnet_name   = module.azure_transit.vpc.name
  vnet_1_id               = module.azure_vnets["spoke-vnet-1"].vnet_id
  vnet_2_id               = module.azure_vnets["spoke-vnet-2"].vnet_id
  depends_on = [
    module.azure_transit
  ]
}


resource "aviatrix_transit_external_device_conn" "vwan_to_avx" {
  vpc_id                    = module.azure_transit.vpc.vpc_id
  connection_name           = var.vwan_avx_connection_name
  gw_name                   = module.azure_transit.transit_gateway.gw_name
  connection_type           = "bgp"
  tunnel_protocol           = "LAN"
  remote_vpc_name           = format("%s:%s:%s", local.vnet_name, local.resource_group, local.subscription_id)
  ha_enabled                = true
  bgp_local_as_num          = module.azure_transit.transit_gateway.local_as_number
  bgp_remote_as_num         = var.bgp_remote_as_num
  backup_bgp_remote_as_num  = var.backup_bgp_remote_as_num
  remote_lan_ip             = tolist(module.azure_native.virtual_hub_ips)[0]
  backup_remote_lan_ip      = tolist(module.azure_native.virtual_hub_ips)[1]
  enable_bgp_lan_activemesh = true
  depends_on = [
    module.azure_native,
    module.azure_transit
  ]
  lifecycle {
    ignore_changes = all
  }
}






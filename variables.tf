variable "region" {
  description = "Azure Virtual WAN region"
}

variable "rg_name" {
  description = "Resource Group Name"
}

variable "vwan_name" {
  description = "Virtual WAN name"
}

variable "vwan_hub_name" {
  description = "Virtual WAN hub name"
}

variable "vwan_hub_prefix" {
  description = "Virtual WAN hub address prefix"
}

variable "transit_cidr" {
  description = "transit CIDR address prefix"
}

variable "ctrl_azure_acc" {
  description = "Azure account name in the controller"
}

variable "avx_transit_gateway_asn" {
  description = "Aviatrix transit gateway ASN"
}

locals {
  split_data      = split("/", values(data.azurerm_virtual_network.example.vnet_peerings)[0])
  subscription_id = local.split_data[2]
  resource_group  = local.split_data[4]
  vnet_name       = local.split_data[8]
}

variable "bgp_remote_as_num" {
  description = "vWAN BGP ASN"
}

variable "backup_bgp_remote_as_num" {
  description = "vWAN BGP ASN"
}

variable "vwan_avx_connection_name" {
  description = "vWAN to Avx connection name"
}

variable "vnet1_pub_subnets" {
  description = "Map of Azure VNET subnet configuration"
  type        = map(any)
}

variable "vnet1_priv_subnets" {
  description = "Map of Azure VNET subnet configuration"
  type        = map(any)
}

variable "vnet2_pub_subnets" {
  description = "Map of Azure VNET subnet configuration"
  type        = map(any)
}

variable "vnet2_priv_subnets" {
  description = "Map of Azure VNET subnet configuration"
  type        = map(any)
}

locals {
  vnet_details = {
    "spoke-vnet-1" = {
      location      = "West Europe",
      rg_name       = "weu-spoke-rgs"
      pub_subnets       = var.vnet1_pub_subnets,
      priv_subnets       = var.vnet1_priv_subnets,
      address_space = ["10.130.0.0/22", "10.20.0.0/27"]
    },
    "spoke-vnet-2" = {
      location      = "West Europe",
      rg_name       = "weu-spoke-rgs"
      pub_subnets       = var.vnet2_pub_subnets,
      priv_subnets       = var.vnet2_priv_subnets,
      address_space = ["10.130.4.0/22", "10.21.0.0/27"]
    }
  }
}
rg_name                  = "vwan-rg"
vwan_name                = "orsted_vwan"
region                   = "West Europe"
vwan_hub_name            = "orsted_hub"
vwan_hub_prefix          = "10.1.0.0/24"
transit_cidr             = "10.200.0.0/23"
ctrl_azure_acc           = "azure-acc"
avx_transit_gateway_asn  = "65516"
bgp_remote_as_num        = "65515"
backup_bgp_remote_as_num = "65515"
vwan_avx_connection_name = "vwan_to_avx"

vnet1_pub_subnets = {
  pub_subnet_1 = {
    name                 = "pub_sub_1"
    resource_group_name  = "weu-spoke-rgs"
    virtual_network_name = "spoke-vnet-1"
    address_prefixes     = ["10.130.1.0/26"]
  },
}

vnet1_priv_subnets = {
  private_subnet_1 = {
    name                 = "private_sub_1"
    resource_group_name  = "weu-spoke-rgs"
    virtual_network_name = "spoke-vnet-1"
    address_prefixes     = ["10.130.1.64/26"]
  },
  private_subnet_2 = {
    name                 = "private_sub_2"
    resource_group_name  = "weu-spoke-rgs"
    virtual_network_name = "spoke-vnet-1"
    address_prefixes     = ["10.130.1.128/26"]
  },
}

vnet2_pub_subnets = {
  pub_subnet_1 = {
    name                 = "pub_sub_1"
    resource_group_name  = "weu-spoke-rgs"
    virtual_network_name = "spoke-vnet-2"
    address_prefixes     = ["10.130.4.0/26"]
  },
}

vnet2_priv_subnets = {
  private_subnet_1 = {
    name                 = "private_sub_1"
    resource_group_name  = "weu-spoke-rgs"
    virtual_network_name = "spoke-vnet-2"
    address_prefixes     = ["10.130.4.64/26"]
  },
}
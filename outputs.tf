

output "public_ip_vnet1" {
  value = module.azure_vnets["spoke-vnet-1"].public_ip_address
}

output "public_ip_vnet2" {
  value = module.azure_vnets["spoke-vnet-2"].public_ip_address
}

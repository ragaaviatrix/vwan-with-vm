resource "azurerm_resource_group" "example" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = var.address_space
}

resource "azurerm_subnet" "pub_subnet" {
  for_each = var.pub_subnets

  name                 = each.value.name
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.virtual_network_name
  address_prefixes     = each.value.address_prefixes
  depends_on           = [azurerm_virtual_network.vnet]
}

resource "azurerm_subnet" "priv_subnet" {
  for_each = var.priv_subnets

  name                 = each.value.name
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.virtual_network_name
  address_prefixes     = each.value.address_prefixes
  depends_on           = [azurerm_virtual_network.vnet]
}

resource "azurerm_route_table" "pub_rt" {
  name                = "public-rt-${var.vnet_name}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_route_table" "priv_rt" {
  name                = "priv-rt-${var.vnet_name}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_route" "default_route" {
  name                = "defaultroute"
  resource_group_name = azurerm_resource_group.example.name
  route_table_name    = azurerm_route_table.pub_rt.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
}

resource "azurerm_route" "blackhole" {
  name                = "blackhole"
  resource_group_name = azurerm_resource_group.example.name
  route_table_name    = azurerm_route_table.priv_rt.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "None"
}

resource "azurerm_subnet_route_table_association" "pub_rt_associate" {
  for_each       = azurerm_subnet.pub_subnet
  subnet_id      = each.value.id
  route_table_id = azurerm_route_table.pub_rt.id
}

resource "azurerm_subnet_route_table_association" "priv_rt_associate" {
  for_each       = azurerm_subnet.priv_subnet
  subnet_id      = each.value.id
  route_table_id = azurerm_route_table.priv_rt.id
}

resource "azurerm_public_ip" "public_ip_spoke_vm" {
  name                = "public_ip-${var.vnet_name}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "pub_avx_spk" {
  name                = "vm-nic-${var.vnet_name}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "ip-vm-${var.vnet_name}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_spoke_vm.id
    subnet_id                     = azurerm_subnet.pub_subnet[sort(keys(var.pub_subnets))[0]].id
  }
}

resource "azurerm_network_security_group" "pub_spk_my_terraform_nsg" {
  name                = "NSG-${var.vnet_name}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "pub_avx_spk_nsg" {
  network_interface_id      = azurerm_network_interface.pub_avx_spk.id
  network_security_group_id = azurerm_network_security_group.pub_spk_my_terraform_nsg.id
}

resource "azurerm_linux_virtual_machine" "example" {
  name                  = "vm-test-${var.vnet_name}"
  resource_group_name   = azurerm_resource_group.example.name
  location              = azurerm_resource_group.example.location
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  network_interface_ids = ["${azurerm_network_interface.pub_avx_spk.id}"]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  # custom_data = base64encode(<<-EOF
  #               #!/bin/bash
  #               sudo apt update -y
  #               sudo apt upgrade -y
  #               sudo apt-get -y install traceroute
  #               EOF
  # )

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

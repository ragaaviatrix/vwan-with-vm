variable "vnet_name" {
  type    = string

}

variable "rg_name" {
  type    = string

}

variable "location" {
  type    = string

}

variable "address_space" {
  type    = list(any)
}

variable "pub_subnets" {
  description = "Map of Azure VNET subnet configuration"
  type        = map(any)
}

variable "priv_subnets" {
  description = "Map of Azure VNET subnet configuration"
  type        = map(any)
}
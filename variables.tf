variable "resource_group_name" {
  type        = string
  description = "RG name in Azure"
}

variable "resource_group_location" {
  type        = string
  description = "RG location in Azure"
}

variable "azurerm_storage_account" {
  type        = string
  description = " Storage name in Azure"
}

variable "azurerm_storage_container" {
  type        = string
  description = "Storage container name in Azure"
}

variable "azurerm_storage_blob" {
  type        = string
  description = "Storage blob name in Azure"
}

variable "azurerm_virtual_network" {
  type        = string
  description = "Virtual Network name in Azure"
}

variable "azurerm_subnet" {
  type        = string
  description = "Subnet name in Azure"
}

variable "azurerm_private_dns_zone" {
  type        = string
  description = "Private name in Azure"
}
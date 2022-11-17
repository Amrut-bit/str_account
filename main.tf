#Resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}


#StorageAccount
resource "azurerm_storage_account" "sa" {
  name                     = var.azurerm_storage_account
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"
}

resource "azurerm_storage_container" "stcon" {
  name                  = var.azurerm_storage_container
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "stblob" {
  name                   = var.azurerm_storage_blob
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.stcon.name
  type                   = "Block"
  access_tier            = "Cool"
}


#virtualnetwork & Subnet
resource "azurerm_virtual_network" "vnet" {
  name                = var.azurerm_virtual_network
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_subnet" "snet" {
  name                 = var.azurerm_subnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

#DNS zone
resource "azurerm_private_dns_zone" "dns1" {
  name                = var.azurerm_private_dns_zone
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dnszonevnetlink" {
  name                  = "${azurerm_virtual_network.vnet.name}-dnslink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns1.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  depends_on            = [azurerm_private_dns_zone.dns1]
}


private_dns_zone_group {
name                 = data.azurerm_private_dns_zone.dns1.name
private_dns_zone_ids = [azurerm_private_dns_zone.dns1.id]
  }

#PrivateEndPoint
resource "azurerm_private_endpoint" "pe1" {
  name                = "${azurerm_storage_account.sa.name}-blob"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet.id
  
  
  private_service_connection {
    name                           = "${azurerm_storage_account.sa.name}-connection"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
   }
}

resource "azurerm_private_dns_a_record" "privatedns1" {
  name                = azurerm_private_endpoint.pe1.name
  zone_name           = azurerm_private_dns_zone.dns1.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.pe1.private_service_connection.0.private_ip_address]
  depends_on          = [azurerm_private_endpoint.pe1]
}





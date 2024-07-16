resource "alkira_group" "nonprod" {
  name = "nonprod"
}

resource "azurerm_virtual_network" "nonprod" {

  name                = "npe-vnet-useast"
  address_space       = ["10.149.0.0/16"]
  resource_group_name = var.azr_resource_group
  location            = "eastus"

}

resource "azurerm_subnet" "nonprod" {

  name                  = "npe-subnet-useast"
  resource_group_name   = var.azr_resource_group
  virtual_network_name  = azurerm_virtual_network.nonprod.name
  address_prefixes      = ["10.149.1.0/24"]

  depends_on = [
    azurerm_virtual_network.nonprod
  ]

}

resource "alkira_credential_azure_vnet" "nonprod" {
  name            = "azure-nonprod"
  application_id  = var.azr_client_id 
  secret_key      = var.azr_client_secret
  tenant_id       = var.azr_tenant_id
  subscription_id = var.azr_subscription_id
}

resource "alkira_connector_azure_vnet" "training" {
  azure_vnet_id           = azurerm_virtual_network.nonprod.id
  credential_id           = alkira_credential_azure_vnet.nonprod.id
  cxp                     = "US-EAST-2"
  enabled                 = true
  group                   = alkira_group.nonprod.name
  name                    = format("william-%s", "npe-vnet-useast")
  segment_id              = data.alkira_segment.training.id
  size                    = "SMALL"

  vnet_cidr {
    cidr            = "10.149.0.0/16"
    routing_options = "ADVERTISE_DEFAULT_ROUTE"
  }

  depends_on = [
    azurerm_virtual_network.nonprod,
    azurerm_subnet.nonprod
  ]

}
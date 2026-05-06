terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "rg7" {
  name     = "az104-rg7"
  location = var.location
}

resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet1"
  location            = azurerm_resource_group.rg7.location
  resource_group_name = azurerm_resource_group.rg7.name
  address_space       = ["10.70.0.0/16"]
}

resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg7.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.70.0.0/24"]

  service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_storage_account" "storage" {
  name                     = "az104st${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg7.name
  location                 = azurerm_resource_group.rg7.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  access_tier              = "Hot"

  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true

  blob_properties {
    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }
}

resource "azurerm_storage_management_policy" "lifecycle" {
  storage_account_id = azurerm_storage_account.storage.id

  rule {
    name    = "Movetocool"
    enabled = true

    filters {
      blob_types = ["blockBlob"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = 30
      }
    }
  }
}

resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}

resource "azurerm_storage_share" "share1" {
  name               = "share1"
  storage_account_id = azurerm_storage_account.storage.id
  quota              = 5
  access_tier        = "TransactionOptimized"
}

resource "azurerm_storage_account_network_rules" "rules" {
  storage_account_id = azurerm_storage_account.storage.id

  default_action             = "Deny"
  ip_rules                   = [var.client_ip]
  virtual_network_subnet_ids = [azurerm_subnet.default.id]
  bypass                     = ["AzureServices"]
}
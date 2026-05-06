output "resource_group_name" {
  value = azurerm_resource_group.rg7.name
}

output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

output "blob_container_name" {
  value = azurerm_storage_container.data.name
}

output "file_share_name" {
  value = azurerm_storage_share.share1.name
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet1.name
}
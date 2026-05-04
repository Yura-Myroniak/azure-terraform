output "resource_group_name" {
  value = azurerm_resource_group.rg2.name
}

output "storage_account_name" {
  value = azurerm_storage_account.storage_with_tag.name
}

output "lock_name" {
  value = azurerm_management_lock.rg_lock.name
}
output "management_group_name" {
  value = azurerm_management_group.mg1.name
}

output "helpdesk_group" {
  value = azuread_group.helpdesk.display_name
}

output "custom_role" {
  value = azurerm_role_definition.custom_support_request.name
}
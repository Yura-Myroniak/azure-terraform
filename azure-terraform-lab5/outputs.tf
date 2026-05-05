output "resource_group_name" {
  value = azurerm_resource_group.rg5.name
}

output "core_vm_private_ip" {
  value = azurerm_network_interface.core_nic.private_ip_address
}

output "manufacturing_vm_private_ip" {
  value = azurerm_network_interface.manufacturing_nic.private_ip_address
}

output "admin_username" {
  value = "localadmin"
}

output "admin_password" {
  value     = random_password.vm_password.result
  sensitive = true
}

output "route_table" {
  value = azurerm_route_table.rt_core.name
}
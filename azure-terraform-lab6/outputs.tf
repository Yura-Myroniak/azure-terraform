output "resource_group_name" {
  value = azurerm_resource_group.rg6.name
}

output "load_balancer_public_ip" {
  value = azurerm_public_ip.lb_pip.ip_address
}

output "application_gateway_public_ip" {
  value = azurerm_public_ip.appgw_pip.ip_address
}

output "admin_username" {
  value = "localadmin"
}

output "admin_password" {
  value     = random_password.vm_password.result
  sensitive = true
}
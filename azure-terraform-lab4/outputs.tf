output "resource_group_name" {
  value = azurerm_resource_group.rg4.name
}

output "virtual_networks" {
  value = [
    azurerm_virtual_network.core.name,
    azurerm_virtual_network.manufacturing.name
  ]
}

output "subnets" {
  value = [
    azurerm_subnet.shared.name,
    azurerm_subnet.database.name,
    azurerm_subnet.sensor1.name,
    azurerm_subnet.sensor2.name
  ]
}

output "application_security_group" {
  value = azurerm_application_security_group.asg_web.name
}

output "network_security_group" {
  value = azurerm_network_security_group.nsg.name
}

output "public_dns_zone" {
  value = azurerm_dns_zone.public_zone.name
}

output "private_dns_zone" {
  value = azurerm_private_dns_zone.private_zone.name
}
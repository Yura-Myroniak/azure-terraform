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

resource "azurerm_resource_group" "rg5" {
  name     = "az104-rg5"
  location = var.location
}

resource "random_password" "vm_password" {
  length           = 16
  special          = true
  override_special = "!@#%"
}

resource "azurerm_virtual_network" "core" {
  name                = "CoreServicesVnet"
  location            = azurerm_resource_group.rg5.location
  resource_group_name = azurerm_resource_group.rg5.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "core" {
  name                 = "Core"
  resource_group_name  = azurerm_resource_group.rg5.name
  virtual_network_name = azurerm_virtual_network.core.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "perimeter" {
  name                 = "perimeter"
  resource_group_name  = azurerm_resource_group.rg5.name
  virtual_network_name = azurerm_virtual_network.core.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_virtual_network" "manufacturing" {
  name                = "ManufacturingVnet"
  location            = azurerm_resource_group.rg5.location
  resource_group_name = azurerm_resource_group.rg5.name
  address_space       = ["172.16.0.0/16"]
}

resource "azurerm_subnet" "manufacturing" {
  name                 = "Manufacturing"
  resource_group_name  = azurerm_resource_group.rg5.name
  virtual_network_name = azurerm_virtual_network.manufacturing.name
  address_prefixes     = ["172.16.0.0/24"]
}

resource "azurerm_network_interface" "core_nic" {
  name                = "CoreServicesVM-nic"
  location            = azurerm_resource_group.rg5.location
  resource_group_name = azurerm_resource_group.rg5.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.core.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "manufacturing_nic" {
  name                = "ManufacturingVM-nic"
  location            = azurerm_resource_group.rg5.location
  resource_group_name = azurerm_resource_group.rg5.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.manufacturing.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "core_vm" {
  name                = "CoreServicesVM"
  resource_group_name = azurerm_resource_group.rg5.name
  location            = azurerm_resource_group.rg5.location
  size                = var.vm_size
  admin_username      = "localadmin"
  admin_password      = random_password.vm_password.result

  network_interface_ids = [
    azurerm_network_interface.core_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  boot_diagnostics {}
}

resource "azurerm_windows_virtual_machine" "manufacturing_vm" {
  name                = "ManufacturingVM"
  resource_group_name = azurerm_resource_group.rg5.name
  location            = azurerm_resource_group.rg5.location
  size                = var.vm_size
  admin_username      = "localadmin"
  admin_password      = random_password.vm_password.result

  network_interface_ids = [
    azurerm_network_interface.manufacturing_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  boot_diagnostics {}
}

resource "azurerm_virtual_network_peering" "core_to_manufacturing" {
  name                         = "CoreServicesVnet-to-ManufacturingVnet"
  resource_group_name          = azurerm_resource_group.rg5.name
  virtual_network_name         = azurerm_virtual_network.core.name
  remote_virtual_network_id    = azurerm_virtual_network.manufacturing.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "manufacturing_to_core" {
  name                         = "ManufacturingVnet-to-CoreServicesVnet"
  resource_group_name          = azurerm_resource_group.rg5.name
  virtual_network_name         = azurerm_virtual_network.manufacturing.name
  remote_virtual_network_id    = azurerm_virtual_network.core.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_route_table" "rt_core" {
  name                          = "rt-CoreServices"
  location                      = azurerm_resource_group.rg5.location
  resource_group_name           = azurerm_resource_group.rg5.name
  bgp_route_propagation_enabled = false

  route {
    name                   = "PerimetertoCore"
    address_prefix         = "10.0.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.1.7"
  }
}

resource "azurerm_subnet_route_table_association" "perimeter_rt" {
  subnet_id      = azurerm_subnet.perimeter.id
  route_table_id = azurerm_route_table.rt_core.id
}
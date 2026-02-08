terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~> 3.0"
        }
    }
}

provider "azurerm" {
    features {}
    subscription_id = var.subscription_id
    client_id       = var.client_id
    client_secret   = var.client_secret
    tenant_id       = var.tenant_id
}

resource "azurerm_resource_group" "main" {
    name     = "rg-sudeste"
    location = "Southeast"
}

resource "azurerm_virtual_network" "main" {
    name                = "vnet-sudeste"
    address_space       = ["10.4.0.0/16"]
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
    name                 = "subnet-internal"
    resource_group_name  = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes     = ["10.4.16.0/24"]
}

resource "azurerm_network_interface" "main" {
    name                = "nic-vm"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name

    ip_configuration {
        name                          = "testconfiguration1"
        subnet_id                     = azurerm_subnet.internal.id
        private_ip_address_allocation = "Static"
        private_ip_address            = "10.4.16.12"
    }
}

resource "azurerm_virtual_machine" "main" {
    name                  = "vm-sudeste"
    location              = azurerm_resource_group.main.location
    resource_group_name   = azurerm_resource_group.main.name
    vm_size               = "Standard_B2s"
    network_interface_ids = [azurerm_network_interface.main.id]

    storage_os_disk {
        name              = "osdisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    os_profile {
        computer_name  = "vm-sudeste"
        admin_username = "azureuser"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = var.ssh_public_key
        }
    }
}
# ─────────────────────────────────────────────────────────────────
# VMs – Spoke 1  (VM-01 and VM-02, no public IP)
# ─────────────────────────────────────────────────────────────────

resource "azurerm_network_interface" "spoke1_vm01" {
  name                = "nic-spoke1-vm01"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.spoke1_workload.id
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id intentionally omitted – no public IP
  }

  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "spoke1_vm01" {
  name                  = "vm-spoke1-01"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  size                  = var.vm_size
  admin_username        = var.vm_admin_username
  admin_password        = var.vm_admin_password
  network_interface_ids = [azurerm_network_interface.spoke1_vm01.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  # No public IP → access via Azure Bastion or private connectivity only
  tags = var.tags
}

resource "azurerm_network_interface" "spoke1_vm02" {
  name                = "nic-spoke1-vm02"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.spoke1_workload.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "spoke1_vm02" {
  name                  = "vm-spoke1-02"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  size                  = var.vm_size
  admin_username        = var.vm_admin_username
  admin_password        = var.vm_admin_password
  network_interface_ids = [azurerm_network_interface.spoke1_vm02.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  tags = var.tags
}

# ─────────────────────────────────────────────────────────────────
# VMs – Spoke 2  (VM-03 and VM-04, no public IP)
# ─────────────────────────────────────────────────────────────────

resource "azurerm_network_interface" "spoke2_vm03" {
  name                = "nic-spoke2-vm03"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.spoke2_workload.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "spoke2_vm03" {
  name                  = "vm-spoke2-03"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  size                  = var.vm_size
  admin_username        = var.vm_admin_username
  admin_password        = var.vm_admin_password
  network_interface_ids = [azurerm_network_interface.spoke2_vm03.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  tags = var.tags
}

resource "azurerm_network_interface" "spoke2_vm04" {
  name                = "nic-spoke2-vm04"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.spoke2_workload.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "spoke2_vm04" {
  name                  = "vm-spoke2-04"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  size                  = var.vm_size
  admin_username        = var.vm_admin_username
  admin_password        = var.vm_admin_password
  network_interface_ids = [azurerm_network_interface.spoke2_vm04.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  tags = var.tags
}

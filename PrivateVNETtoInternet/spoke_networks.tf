# ─────────────────────────────────────────────
# Spoke VNet 1
# ─────────────────────────────────────────────
resource "azurerm_virtual_network" "spoke1" {
  name                = "vnet-spoke1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.spoke1_vnet_address_space

  tags = var.tags
}

resource "azurerm_subnet" "spoke1_workload" {
  name                 = "snet-workload"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.spoke1.name
  address_prefixes     = [var.spoke1_subnet_prefix]
}

# NSG – Spoke 1 workload subnet
resource "azurerm_network_security_group" "spoke1" {
  name                = "nsg-spoke1-workload"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Deny inbound from internet – no public IPs on VMs, but belt-and-suspenders
  security_rule {
    name                       = "deny-inbound-internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Allow inbound from Hub (management / monitoring)
  security_rule {
    name                       = "allow-inbound-from-hub"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }

  # Allow outbound to internet via Firewall only (UDR enforces the path)
  security_rule {
    name                       = "allow-outbound-via-firewall"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.0.0/16"
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "spoke1" {
  subnet_id                 = azurerm_subnet.spoke1_workload.id
  network_security_group_id = azurerm_network_security_group.spoke1.id
}

# ─────────────────────────────────────────────
# Spoke VNet 2
# ─────────────────────────────────────────────
resource "azurerm_virtual_network" "spoke2" {
  name                = "vnet-spoke2"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.spoke2_vnet_address_space

  tags = var.tags
}

resource "azurerm_subnet" "spoke2_workload" {
  name                 = "snet-workload"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.spoke2.name
  address_prefixes     = [var.spoke2_subnet_prefix]
}

# NSG – Spoke 2 workload subnet
resource "azurerm_network_security_group" "spoke2" {
  name                = "nsg-spoke2-workload"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "deny-inbound-internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-inbound-from-hub"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-outbound-via-firewall"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.0.0/16"
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "spoke2" {
  subnet_id                 = azurerm_subnet.spoke2_workload.id
  network_security_group_id = azurerm_network_security_group.spoke2.id
}

# ─────────────────────────────────────────────
# VNet Peering – Hub ↔ Spoke 1 (bidirectional)
# ─────────────────────────────────────────────
resource "azurerm_virtual_network_peering" "hub_to_spoke1" {
  name                         = "peer-hub-to-spoke1"
  resource_group_name          = azurerm_resource_group.main.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke1.id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true  # Hub shares its gateway with Spokes
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "spoke1_to_hub" {
  name                         = "peer-spoke1-to-hub"
  resource_group_name          = azurerm_resource_group.main.name
  virtual_network_name         = azurerm_virtual_network.spoke1.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false  # set to true once a VPN/ER GW is deployed in Hub
}

# ─────────────────────────────────────────────
# VNet Peering – Hub ↔ Spoke 2 (bidirectional)
# ─────────────────────────────────────────────
resource "azurerm_virtual_network_peering" "hub_to_spoke2" {
  name                         = "peer-hub-to-spoke2"
  resource_group_name          = azurerm_resource_group.main.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke2.id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "spoke2_to_hub" {
  name                         = "peer-spoke2-to-hub"
  resource_group_name          = azurerm_resource_group.main.name
  virtual_network_name         = azurerm_virtual_network.spoke2.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

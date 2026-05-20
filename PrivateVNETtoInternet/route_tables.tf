# ─────────────────────────────────────────────
# Route Table – Spoke 1 (force egress via Firewall)
# ─────────────────────────────────────────────
resource "azurerm_route_table" "spoke1" {
  name                          = "rt-spoke1"
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  bgp_route_propagation_enabled = false

  route {
    name                   = "udr-default-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.main.ip_configuration[0].private_ip_address
  }

  tags = var.tags
}

resource "azurerm_subnet_route_table_association" "spoke1" {
  subnet_id      = azurerm_subnet.spoke1_workload.id
  route_table_id = azurerm_route_table.spoke1.id
}

# ─────────────────────────────────────────────
# Route Table – Spoke 2 (force egress via Firewall)
# ─────────────────────────────────────────────
resource "azurerm_route_table" "spoke2" {
  name                          = "rt-spoke2"
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  bgp_route_propagation_enabled = false

  route {
    name                   = "udr-default-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.main.ip_configuration[0].private_ip_address
  }

  tags = var.tags
}

resource "azurerm_subnet_route_table_association" "spoke2" {
  subnet_id      = azurerm_subnet.spoke2_workload.id
  route_table_id = azurerm_route_table.spoke2.id
}

# ─────────────────────────────────────────────
# Route Table – Hub NAT egress subnet
# (traffic from firewall goes straight to internet via NAT GW)
# ─────────────────────────────────────────────
resource "azurerm_route_table" "hub_nat" {
  name                          = "rt-hub-nat-egress"
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  bgp_route_propagation_enabled = false

  route {
    name           = "udr-internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags = var.tags
}

resource "azurerm_subnet_route_table_association" "hub_nat" {
  subnet_id      = azurerm_subnet.hub_nat.id
  route_table_id = azurerm_route_table.hub_nat.id
}

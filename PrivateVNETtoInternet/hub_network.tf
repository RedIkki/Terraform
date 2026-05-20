# ─────────────────────────────────────────────
# Hub VNet
# ─────────────────────────────────────────────
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.hub_vnet_address_space

  tags = var.tags
}

# AzureFirewallSubnet – name is fixed by Azure
resource "azurerm_subnet" "hub_firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_firewall_subnet_prefix]
}

# GatewaySubnet – name is fixed by Azure
resource "azurerm_subnet" "hub_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_gateway_subnet_prefix]
}

# Subnet used to attach the NAT Gateway (egress subnet)
resource "azurerm_subnet" "hub_nat" {
  name                 = "snet-nat-egress"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_nat_subnet_prefix]
}

# ─────────────────────────────────────────────
# Public IP for NAT Gateway (static, standard)
# ─────────────────────────────────────────────
resource "azurerm_public_ip" "nat" {
  name                = "pip-nat-gateway"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  tags = var.tags
}

# ─────────────────────────────────────────────
# NAT Gateway
# ─────────────────────────────────────────────
resource "azurerm_nat_gateway" "main" {
  name                    = "natgw-hub"
  location                = azurerm_resource_group.main.location
  resource_group_name     = azurerm_resource_group.main.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]

  tags = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

# Associate NAT Gateway with the Hub egress subnet
resource "azurerm_subnet_nat_gateway_association" "hub_nat" {
  subnet_id      = azurerm_subnet.hub_nat.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

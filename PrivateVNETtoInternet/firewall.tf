# ─────────────────────────────────────────────
# Public IP for Azure Firewall
# ─────────────────────────────────────────────
resource "azurerm_public_ip" "firewall" {
  name                = "pip-firewall"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  tags = var.tags
}

# ─────────────────────────────────────────────
# Firewall Policy (Premium for IDPS / TLS)
# ─────────────────────────────────────────────
resource "azurerm_firewall_policy" "main" {
  name                = "afwp-hub"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  dns {
    proxy_enabled = true
  }

  tags = var.tags
}

# ─────────────────────────────────────────────
# Rule Collection Group
# ─────────────────────────────────────────────
resource "azurerm_firewall_policy_rule_collection_group" "main" {
  name               = "rcg-hub-egress"
  firewall_policy_id = azurerm_firewall_policy.main.id
  priority           = 200

  # Allow specific FQDNs outbound – adjust to your workload needs
  application_rule_collection {
    name     = "arc-allow-internet-egress"
    priority = 210
    action   = "Allow"

    rule {
      name = "allow-windows-update"
      protocols {
        type = "Https"
        port = 443
      }
      protocols {
        type = "Http"
        port = 80
      }
      source_addresses      = ["10.1.0.0/16", "10.2.0.0/16"]
      destination_fqdn_tags = ["WindowsUpdate"]
    }

    rule {
      name = "allow-azure-services"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["10.1.0.0/16", "10.2.0.0/16"]
      destination_fqdns = ["*.azure.com", "*.microsoft.com", "*.windows.net"]
    }
  }

  # Block everything else by default (implicit deny is built-in,
  # but an explicit deny rule makes audit logs clearer)
  network_rule_collection {
    name     = "nrc-deny-direct-internet"
    priority = 300
    action   = "Deny"

    rule {
      name                  = "deny-all-outbound"
      protocols             = ["Any"]
      source_addresses      = ["10.0.0.0/8"]
      destination_addresses = ["Internet"]
      destination_ports     = ["*"]
    }
  }
}

# ─────────────────────────────────────────────
# Azure Firewall
# ─────────────────────────────────────────────
resource "azurerm_firewall" "main" {
  name                = "afw-hub"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.main.id
  zones               = ["1", "2", "3"]

  ip_configuration {
    name                 = "ipconfig-firewall"
    subnet_id            = azurerm_subnet.hub_firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }

  tags = var.tags
}

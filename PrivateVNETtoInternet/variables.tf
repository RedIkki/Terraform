variable "location" {
  description = "Azure region where resources will be deployed."
  type        = string
  default     = "brazilsouth"
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default = {
    environment = "production"
    topology    = "hub-spoke-private-egress"
    managed_by  = "terraform"
  }
}

# ── Hub ──────────────────────────────────────
variable "hub_vnet_address_space" {
  description = "Address space for the Hub VNet."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "hub_firewall_subnet_prefix" {
  description = "Prefix for AzureFirewallSubnet (name is mandatory by Azure)."
  type        = string
  default     = "10.0.1.0/26"
}

variable "hub_gateway_subnet_prefix" {
  description = "Prefix for GatewaySubnet (name is mandatory by Azure)."
  type        = string
  default     = "10.0.2.0/27"
}

variable "hub_nat_subnet_prefix" {
  description = "Prefix for the NAT Gateway association subnet inside the Hub."
  type        = string
  default     = "10.0.3.0/28"
}

# ── Spoke 1 ──────────────────────────────────
variable "spoke1_vnet_address_space" {
  description = "Address space for Spoke VNet 1."
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "spoke1_subnet_prefix" {
  description = "Prefix for the private workload subnet in Spoke 1."
  type        = string
  default     = "10.1.1.0/24"
}

# ── Spoke 2 ──────────────────────────────────
variable "spoke2_vnet_address_space" {
  description = "Address space for Spoke VNet 2."
  type        = list(string)
  default     = ["10.2.0.0/16"]
}

variable "spoke2_subnet_prefix" {
  description = "Prefix for the private workload subnet in Spoke 2."
  type        = string
  default     = "10.2.1.0/24"
}

# ── VMs ──────────────────────────────────────
variable "vm_size" {
  description = "SKU for all test VMs."
  type        = string
  default     = "Standard_B2s"
}

variable "vm_admin_username" {
  description = "Local admin username for the VMs."
  type        = string
  default     = "azureadmin"
}

variable "vm_admin_password" {
  description = "Local admin password for the VMs. Must satisfy Azure complexity requirements."
  type        = string
  sensitive   = true
}

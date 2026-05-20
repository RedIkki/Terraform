output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.main.name
}

output "hub_vnet_id" {
  description = "Resource ID of the Hub VNet."
  value       = azurerm_virtual_network.hub.id
}

output "spoke1_vnet_id" {
  description = "Resource ID of Spoke VNet 1."
  value       = azurerm_virtual_network.spoke1.id
}

output "spoke2_vnet_id" {
  description = "Resource ID of Spoke VNet 2."
  value       = azurerm_virtual_network.spoke2.id
}

output "nat_gateway_public_ip" {
  description = "Public IP address assigned to the NAT Gateway (shared egress IP for all VMs)."
  value       = azurerm_public_ip.nat.ip_address
}

output "firewall_private_ip" {
  description = "Private IP of the Azure Firewall – used as next-hop in UDRs."
  value       = azurerm_firewall.main.ip_configuration[0].private_ip_address
}

output "firewall_public_ip" {
  description = "Public IP of the Azure Firewall (management / DNAT rules)."
  value       = azurerm_public_ip.firewall.ip_address
}

output "spoke1_vm_private_ips" {
  description = "Private IP addresses of VMs in Spoke 1."
  value = {
    vm01 = azurerm_network_interface.spoke1_vm01.private_ip_address
    vm02 = azurerm_network_interface.spoke1_vm02.private_ip_address
  }
}

output "spoke2_vm_private_ips" {
  description = "Private IP addresses of VMs in Spoke 2."
  value = {
    vm03 = azurerm_network_interface.spoke2_vm03.private_ip_address
    vm04 = azurerm_network_interface.spoke2_vm04.private_ip_address
  }
}

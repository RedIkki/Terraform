# Hub-and-Spoke – Private VNet Internet Egress

Terraform que provisiona a topologia descrita no diagrama:
VMs em subnets privadas (sem IP público) acessam a internet exclusivamente
através do **Azure Firewall** (inspeção + FQDN filtering) e do **NAT Gateway**
(SNAT com IP estático compartilhado).

## Arquitetura

```
Internet
    │  (IP público estático do NAT Gateway)
    ▼
NAT Gateway
    │
Azure Firewall  ◄── UDR 0.0.0.0/0 dos Spokes
    │
Hub VNet (10.0.0.0/16)
    ├── AzureFirewallSubnet  (10.0.1.0/26)
    ├── GatewaySubnet        (10.0.2.0/27)
    └── snet-nat-egress      (10.0.3.0/28)

VNet Peering (bidirecional)

Spoke VNet 1 (10.1.0.0/16)          Spoke VNet 2 (10.2.0.0/16)
└── snet-workload (10.1.1.0/24)     └── snet-workload (10.2.1.0/24)
    ├── vm-spoke1-01                     ├── vm-spoke2-03
    └── vm-spoke1-02                     └── vm-spoke2-04
```

## Recursos criados

| Recurso | Nome | Finalidade |
|---|---|---|
| Resource Group | rg-PrivateVNETtoInternet | Contêiner de todos os recursos |
| VNet Hub | vnet-hub | Centraliza firewall e gateway |
| VNet Spoke 1 | vnet-spoke1 | Workload isolado |
| VNet Spoke 2 | vnet-spoke2 | Workload isolado |
| NAT Gateway | natgw-hub | SNAT de saída com IP fixo |
| Azure Firewall | afw-hub | Inspeção e FQDN filtering |
| Firewall Policy | afwp-hub | Regras de aplicação e rede |
| Route Table x3 | rt-spoke1/2, rt-hub-nat-egress | UDR forçando tráfego pelo firewall |
| NSG x2 | nsg-spoke1/2-workload | Deny internet inbound, allow hub |
| VMs x4 | vm-spoke1-01/02, vm-spoke2-03/04 | Sem IP público |

## Pré-requisitos

- Terraform >= 1.5.0
- Azure CLI autenticado (`az login`) ou Service Principal configurado
- Permissão de **Contributor** no subscription

## Como usar

```bash
# 1. Clone / copie os arquivos
cd terraform-private-vnet

# 2. Configure suas variáveis
cp terraform.tfvars.example terraform.tfvars
# edite terraform.tfvars com seus valores (especialmente vm_admin_password)

# 3. Inicialize
terraform init

# 4. Valide
terraform validate
terraform plan -out=tfplan

# 5. Aplique
terraform apply tfplan
```

> **Atenção:** O Azure Firewall tem custo fixo por hora (~$1,25/h na região Brazil South).
> Destrua o ambiente quando não precisar: `terraform destroy`

## Acesso às VMs

As VMs não possuem IP público. Para acessá-las, use uma das opções:

- **Azure Bastion** – adicione um recurso `azurerm_bastion_host` na `BastionSubnet` do Hub
- **Just-in-Time VM Access** (Microsoft Defender for Cloud)
- **VPN Point-to-Site** via o GatewaySubnet já provisionado

## Senhas e segredos

Em produção, substitua `vm_admin_password` por uma referência ao **Azure Key Vault**:

```hcl
data "azurerm_key_vault_secret" "vm_password" {
  name         = "vm-admin-password"
  key_vault_id = azurerm_key_vault.main.id
}
```

## Personalização das regras do Firewall

Edite `firewall.tf` → `azurerm_firewall_policy_rule_collection_group.main` para:
- Adicionar FQDNs permitidos em `destination_fqdns`
- Criar regras de rede adicionais por porta/protocolo
- Habilitar o tier **Premium** para IDPS e inspeção TLS

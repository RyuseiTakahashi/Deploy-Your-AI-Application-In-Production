# Example Templates

This directory contains example Bicep templates that are **NOT** part of the main deployment but are provided as references for creating prerequisite resources.

## Purview Account Creation

The main solution accelerator requires an **existing Microsoft Purview account**. If you need to create one, use the templates in this directory.

### Quick Start

```bash
# Create a resource group for Purview
az group create --name rg-purview --location eastus2

# Deploy the Purview account
az deployment group create \
  --resource-group rg-purview \
  --template-file purview-account.bicep \
  --parameters purview-account.bicepparam

# Get the Purview account resource ID
PURVIEW_RESOURCE_ID=$(az deployment group show \
  --resource-group rg-purview \
  --name purview-account \
  --query properties.outputs.purviewAccountId.value -o tsv)

# Set it as an azd environment variable
azd env set purviewAccountResourceId "$PURVIEW_RESOURCE_ID"

# Now deploy the main solution
azd up
```

### Files

| File | Description |
|------|-------------|
| `purview-account.bicep` | Bicep template for creating a Purview account |
| `purview-account.bicepparam` | Parameters file with example values |
| `README.md` | This file |

### Notes

- Purview account names must be **globally unique** across all of Azure
- The managed resource group is created automatically and managed by Purview
- Default deployment enables public network access; set `publicNetworkAccess = 'Disabled'` for private-only access (requires private endpoints)
- Deployment typically takes 5-10 minutes

### Alternative Methods

If you prefer not to use Bicep, see the [Purview Account Creation Guide](../../docs/create_purview_account.md) for alternative methods including:
- Azure Portal (via Resource Group)
- Azure CLI
- Terraform
- PowerShell

### Troubleshooting

If you encounter marketplace errors when creating Purview through the Azure Portal, see the [Purview Account Creation Guide](../../docs/create_purview_account.md) for workarounds.

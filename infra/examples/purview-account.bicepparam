// Parameters file for deploying a Purview account
// Usage: az deployment group create --resource-group <rg> --template-file purview-account.bicep --parameters purview-account.bicepparam

using './purview-account.bicep'

// IMPORTANT: Change this to a globally unique name
param purviewAccountName = 'purview-${uniqueString(subscription().subscriptionId, resourceGroup().id)}'

// Optional: Specify the location (defaults to resource group location)
// param location = 'eastus2'

// Optional: Specify a custom managed resource group name
// param managedResourceGroupName = 'managed-rg-purview'

// Optional: Disable public network access (requires private endpoints)
// param publicNetworkAccess = 'Disabled'

// Optional: Add tags
param tags = {
  Environment: 'Production'
  Project: 'AI-Application-In-Production'
  ManagedBy: 'Bicep'
}

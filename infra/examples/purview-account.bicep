// This is a sample Bicep template for creating a Microsoft Purview account
// NOTE: This template is NOT part of the main deployment. It is provided as a reference
// for users who need to create a Purview account before deploying this solution accelerator.

@description('Purview account name (must be globally unique)')
@minLength(3)
@maxLength(63)
param purviewAccountName string

@description('Location for the Purview account')
param location string = resourceGroup().location

@description('Name for the managed resource group (auto-generated if not specified)')
param managedResourceGroupName string = 'managed-rg-${purviewAccountName}'

@description('Public network access setting')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Tags to apply to the Purview account')
param tags object = {}

// Purview Account
resource purviewAccount 'Microsoft.Purview/accounts@2021-07-01' = {
  name: purviewAccountName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedResourceGroupName: managedResourceGroupName
    publicNetworkAccess: publicNetworkAccess
  }
}

// Outputs
@description('The resource ID of the Purview account')
output purviewAccountId string = purviewAccount.id

@description('The name of the Purview account')
output purviewAccountName string = purviewAccount.name

@description('The catalog endpoint of the Purview account')
output catalogEndpoint string = purviewAccount.properties.endpoints.catalog

@description('The scan endpoint of the Purview account')
output scanEndpoint string = purviewAccount.properties.endpoints.scan

@description('The managed resource group name')
output managedResourceGroupName string = purviewAccount.properties.managedResourceGroupName

@description('The principal ID of the system-assigned managed identity')
output principalId string = purviewAccount.identity.principalId

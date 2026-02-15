@description('CAF-compliant name for the Key Vault')
param keyVaultName string = 'kv-almchatbot-prod-weu'

@description('Resource location')
param location string = 'westeurope'

@description('Enable public network access? Should be Disabled for PROD')
param publicNetworkAccess string = 'Disabled'

@description('SKU of Key Vault')
param skuName string = 'standard' // standard | premium

@description('Enable RBAC Authorization instead of Access Policies')
param enableRbacAuthorization bool = true

@description('Soft delete retention days (7–90)')
param softDeleteRetentionDays int = 30

@description('Enable purge protection')
param enablePurgeProtection bool = true

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location

  properties: {
    enableRbacAuthorization: enableRbacAuthorization
    enabledForDeployment: false
    enabledForTemplateDeployment: false
    enabledForDiskEncryption: false

    tenantId: tenant().tenantId
    sku: {
      family: 'A'
      name: skuName
    }

    networkAcls: {
      defaultAction: publicNetworkAccess == 'Disabled' ? 'Deny' : 'Allow'
      bypass: 'AzureServices'
    }

    softDeleteRetentionInDays: softDeleteRetentionDays
    enablePurgeProtection: enablePurgeProtection
  }
}

output keyVaultId string = keyVault.id

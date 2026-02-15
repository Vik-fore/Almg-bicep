targetScope = 'resourceGroup'

@description('Deployment location. Defaults to the resource group location.')
param location string = resourceGroup().location

// ---------- Key Vault (PROD-style) ----------

@description('CAF-compliant name for the Key Vault')
param keyVaultName string = 'kv-almchatbot-prod-weu'

@description('Enable public network access? Should be Disabled for PROD')
@allowed([
  'Enabled'
  'Disabled'
])
param keyVaultPublicNetworkAccess string = 'Disabled'

@description('SKU of Key Vault')
@allowed([
  'standard'
  'premium'
])
param keyVaultSkuName string = 'standard'

@description('Enable RBAC Authorization instead of Access Policies')
param enableRbacAuthorization bool = true

@description('Soft delete retention days (7–90)')
@minValue(7)
@maxValue(90)
param softDeleteRetentionDays int = 30

@description('Enable purge protection')
param enablePurgeProtection bool = true

module keyVault './storage/keyvault/keyvault.bicep' = {
  name: 'deploy-keyvault'
  params: {
    keyVaultName: keyVaultName
    location: location
    publicNetworkAccess: keyVaultPublicNetworkAccess
    skuName: keyVaultSkuName
    enableRbacAuthorization: enableRbacAuthorization
    softDeleteRetentionDays: softDeleteRetentionDays
    enablePurgeProtection: enablePurgeProtection
  }
}

// -------------------------
// Storage Account (PROD-style)
// -------------------------
@description('Name of the Storage Account for PROD')
param storageAccountName string = 'stalmchatbotprod'

@description('SKU / Replication type')
param storageSkuName string = 'Standard_GRS'

@description('Allow public blob access?')
param allowBlobPublicAccess bool = false

@description('Minimum TLS version')
param minTlsVersion string = 'TLS1_2'

module storage './storage/storage.bicep' = {
  name: 'deploy-storage'
  params: {
    storageAccountName: storageAccountName
    location: location
    storageSkuName: storageSkuName
    allowBlobPublicAccess: allowBlobPublicAccess
    minTlsVersion: minTlsVersion
  }
  // Note: no hard dependency on Key Vault here.
  // Keep foundation resources loosely coupled unless required.
}


// Outputs
// -------------------------
output keyVaultId string = keyVault.outputs.keyVaultId
output keyVaultNameOut string = keyVaultName
output storageId string = storage.outputs.storageId

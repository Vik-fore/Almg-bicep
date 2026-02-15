targetScope = 'resourceGroup'

// =====================================================
// MAIN FOUNDATION (UPDATE ONLY)
// This file intentionally DOES NOT create:
// - Private Endpoints
// - Private DNS Zones
// - Private DNS Zone Groups
// It ONLY updates existing Storage / SQL Server / Key Vault settings.
// =====================================================

// --------------------
// Existing resource names
// --------------------
@description('Existing Storage Account name')
param storageAccountName string

@description('Existing SQL Server name')
param sqlServerName string

@description('Existing Key Vault name')
param keyVaultName string

// --------------------
// Existing resource locations (must match the existing resources)
// --------------------
@description('Storage Account location (e.g. westeurope)')
param storageLocation string = 'westeurope'

@description('SQL Server location (e.g. westeurope)')
param sqlLocation string = 'westeurope'

@description('Key Vault location (e.g. swedencentral)')
param keyVaultLocation string = 'swedencentral'

// --------------------
// Storage required fields (Bicep type requires kind + sku even for updates)
// IMPORTANT: Must match the existing Storage Account.
// --------------------
@description('Storage Account kind (must match existing), usually StorageV2')
param storageKind string = 'StorageV2'

@description('Storage SKU name (must match existing), e.g. Standard_GRS / Standard_LRS / Standard_ZRS')
param storageSkuName string = 'Standard_GRS'


// =====================================================
// UPDATE: STORAGE (existing)
// =====================================================
resource stgUpdate 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: storageLocation
  kind: storageKind
  sku: {
    name: storageSkuName
  }
  properties: {
    // Disable public access to the Storage Account
    publicNetworkAccess: 'Disabled'

    // Prevent public blob/container access
    allowBlobPublicAccess: false

    // Deny network access by default (Private Endpoints only)
    networkAcls: {
      defaultAction: 'Deny'

      // Keep this for compatibility; tighten later to 'None' if you want maximum lockdown.
      bypass: 'None'

      ipRules: []
      virtualNetworkRules: []
    }

    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

// =====================================================
// UPDATE: SQL SERVER (existing)
// =====================================================
resource sqlUpdate 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: sqlLocation
  properties: {
    // Disable public access to the SQL Server
    publicNetworkAccess: 'Disabled'
  }
}

// =====================================================
// UPDATE: KEY VAULT (existing)
// =====================================================
resource kvUpdate 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: keyVaultLocation
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }

    // RBAC model (recommended)
    enableRbacAuthorization: true

    // Disable public access to the Key Vault
    publicNetworkAccess: 'Disabled'

    // Deny by default (Private Endpoints only)
    networkAcls: {
      defaultAction: 'Deny'

      // Keep this for compatibility; tighten later to 'None' if desired.
      bypass: 'None'

      ipRules: []
      virtualNetworkRules: []
    }
  }
}

// =====================================================
// OUTPUTS (for visibility/debugging only)
// =====================================================
output storageId string = resourceId('Microsoft.Storage/storageAccounts', storageAccountName)
output sqlServerId string = resourceId('Microsoft.Sql/servers', sqlServerName)
output keyVaultId string = resourceId('Microsoft.KeyVault/vaults', keyVaultName)

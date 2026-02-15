targetScope = 'resourceGroup'

@description('Name of the App Service (Microsoft.Web/sites).')
param appServiceName string

@description('Enable Deny All after allowing Front Door. Set false for safe rollout (only adds Allow rule).')
param enableDenyAll bool = false

@description('Priority for Allow Front Door rule (lower = evaluated first).')
param allowFrontDoorPriority int = 100

@description('Priority for Deny All rule.')
param denyAllPriority int = 200

// Existing App Service
resource app 'Microsoft.Web/sites@2022-09-01' existing = {
  name: appServiceName
}

// Update web config with access restrictions
resource webConfig 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: app
  name: 'web'
  properties: {
    ipSecurityRestrictions: concat(
      [
        {
          name: 'Allow-AzureFrontDoor-Backend'
          action: 'Allow'
          priority: allowFrontDoorPriority
          ipAddress: 'AzureFrontDoor.Backend'
          tag: 'ServiceTag'
          description: 'Allow traffic only from Azure Front Door to the origin'
        }
      ],
      enableDenyAll
        ? [
            {
              name: 'Deny-All'
              action: 'Deny'
              priority: denyAllPriority
              ipAddress: '0.0.0.0/0'
              description: 'Deny all other inbound traffic'
            }
          ]
        : []
    )
  }
}

output appliedTo string = app.name

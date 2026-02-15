targetScope = 'resourceGroup'

@description('Web App name (in the same resource group where this deployment runs)')
param webAppName string

@description('Allowed developer/VPN IP CIDRs, e.g. ["1.2.3.4/32"]')
param allowedDevIps array = []

@description('Allow Azure Front Door backend service tag')
param allowFrontDoorServiceTag bool = true

@description('Add Deny-All rule (0.0.0.0/0)')
param denyAll bool = true

@description('Apply same rules to SCM/Kudu endpoint as well')
param applyToScm bool = true

resource webApp 'Microsoft.Web/sites@2022-09-01' existing = {
  name: webAppName
}

var devRules = [
  for (ip, i) in allowedDevIps: {
    name: 'Allow-Dev-${i}'
    action: 'Allow'
    ipAddress: ip
    priority: 100 + i
    description: 'Allow developer/VPN IP'
    tag: 'Default'
  }
]

var afdRules = allowFrontDoorServiceTag ? [
  {
    name: 'Allow-AzureFrontDoor-Backend'
    action: 'Allow'
    ipAddress: 'AzureFrontDoor.Backend'
    priority: 200
    description: 'Allow traffic from Azure Front Door backend service tag'
    tag: 'ServiceTag'
  }
] : []

var denyRules = denyAll ? [
  {
    name: 'Deny-All'
    action: 'Deny'
    ipAddress: '0.0.0.0/0'
    priority: 1100
    description: 'Deny all other inbound traffic'
    tag: 'Default'
  }
] : []

var rules = concat(devRules, afdRules, denyRules)

// ✅ Correct: use parent + child name "web" (no linter warning)
resource webConfig 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: webApp
  name: 'web'
  properties: union(
    {
      ipSecurityRestrictionsDefaultAction: 'Deny'
      ipSecurityRestrictions: rules
    },
    applyToScm ? {
      scmIpSecurityRestrictionsDefaultAction: 'Deny'
      scmIpSecurityRestrictions: rules
    } : {}
  )
}

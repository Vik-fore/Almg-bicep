targetScope = 'resourceGroup'

@description('Existing Web App name')
param webAppName string

@description('Optional: allow developer office/VPN public IPs (CIDR). Example: ["1.2.3.4/32","5.6.7.0/24"]')
param allowedDevIps array = []

@description('Base priority for rules (lower = higher priority)')
param priorityBase int = 100

resource webApp 'Microsoft.Web/sites@2023-01-01' existing = {
  name: webAppName
}

var devRules = [
  for (ip, i) in allowedDevIps: {
    name: 'Allow-Dev-${i}'
    priority: priorityBase + i
    action: 'Allow'
    ipAddress: string(ip)
    description: 'Allow developer/VPN IP'
  }
]

// IMPORTANT:
// For App Service access restrictions, Service Tag is defined via:
// - ipAddress: 'AzureFrontDoor.Backend'
// - tag: 'ServiceTag'
var afdRule = [
  {
    name: 'Allow-AzureFrontDoor-Backend'
    priority: priorityBase + 100
    action: 'Allow'
    ipAddress: 'AzureFrontDoor.Backend'
    tag: 'ServiceTag'
    description: 'Allow traffic from Azure Front Door backend service tag'
  }
]

var denyAllRule = [
  {
    name: 'Deny-All'
    priority: priorityBase + 1000
    action: 'Deny'
    ipAddress: '0.0.0.0/0'
    description: 'Deny all other inbound traffic'
  }
]

var siteRules = concat(devRules, afdRule, denyAllRule)
var scmRules  = concat(devRules, afdRule, denyAllRule)

resource webConfig 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: webApp
  name: 'web'
  properties: {
    ipSecurityRestrictions: siteRules
    scmIpSecurityRestrictions: scmRules
    scmIpSecurityRestrictionsUseMain: false
  }
}

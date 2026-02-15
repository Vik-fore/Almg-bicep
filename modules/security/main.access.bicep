targetScope = 'resourceGroup'

@description('Production Web App name')
param webAppName string

module access '../app/accessRestrictions.bicep' = {
  name: 'accessRestrictions-${webAppName}'
  params: {
    webAppName: webAppName
    allowedDevIps: [] // No direct IP allowlist in production
    allowFrontDoorServiceTag: true // Allow Azure Front Door to reach the origin
    denyAll: true // Block all other inbound traffic to the app
    applyToScm: false // Keep SCM/Kudu unchanged in this deployment
  }
}

targetScope = 'resourceGroup'

@description('Existing Web App name')
param webAppName string

@description('Subnet resource ID for App Service VNet Integration (delegated to Microsoft.Web/serverFarms)')
param subnetId string

// Existing Web App
resource webApp 'Microsoft.Web/sites@2023-01-01' existing = {
  name: webAppName
}

// Regional VNet Integration (Swift)
resource vnetIntegration 'Microsoft.Web/sites/networkConfig@2022-09-01' = {
  parent: webApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: subnetId
  }
}

output appliedSubnetId string = subnetId

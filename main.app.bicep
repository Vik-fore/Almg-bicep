targetScope = 'resourceGroup'

@description('Deployment location')
param location string = resourceGroup().location

@description('App Service Plan name')
param appServicePlanName string = 'asp-alm-chatbot-prod-weu'

@description('Web App name (must be globally unique)')
param webAppName string = 'alm-chatbot-prod-app-test'

@description('App Service Plan SKU')
@allowed([
  'B1'
  'B2'
  'B3'
])
param skuName string = 'B1'

@description('Subnet resource ID for App Service VNet Integration (existing)')
param subnetId string

@description('Startup command for Python (FastAPI)')
param startupCommand string = 'gunicorn -w 1 -k uvicorn.workers.UvicornWorker -b 0.0.0.0:8000 main:app'

/*
====================================================
 App Service Plan (Linux)
====================================================
*/
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  sku: {
    name: skuName
    tier: 'Basic'
    capacity: 1
  }
  properties: {
    reserved: true
  }
}

/*
====================================================
 Linux Web App (Python 3.12)
====================================================
*/
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true

    // ✅ VNet Integration via existing subnet (cross-RG safe)
    virtualNetworkSubnetId: subnetId

    siteConfig: {
      linuxFxVersion: 'PYTHON|3.12'
      appCommandLine: startupCommand
    }
  }
}

/*
====================================================
 App Settings (minimal, no secrets)
====================================================
*/
resource appSettings 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: webApp
  name: 'appsettings'
  properties: {
    WEBSITES_RUN_FROM_PACKAGE: '1'
  }
}

/*
====================================================
 Outputs
====================================================
*/
output webAppNameOut string = webApp.name
output webAppHostName string = webApp.properties.defaultHostName
output webAppPrincipalId string = webApp.identity.principalId
output appServicePlanId string = appServicePlan.id

@description('Existing Front Door profile name')
param frontdoorProfileName string

@description('Name of the origin group')
param originGroupName string = 'og-alm-chatbot-prod'

@description('Name of the origin inside the group')
param originName string = 'orig-alm-chatbot-prod-app'

@description('Backend host name of App Service (without https://)')
param appServiceHostName string = 'alm-chatbot-prod-app.azurewebsites.net'

// Existing Front Door Standard/Premium profile
resource fdProfile 'Microsoft.Cdn/profiles@2023-05-01' existing = {
  name: frontdoorProfileName
}

// Origin group is a child of the profile (NOT of afdEndpoints)
resource originGroup 'Microsoft.Cdn/profiles/originGroups@2023-05-01' = {
  parent: fdProfile
  name: originGroupName
  properties: {
    // Disable session affinity
    sessionAffinityState: 'Disabled'

    // Health probe configuration
    healthProbeSettings: {
      probePath: '/health'
      probeRequestType: 'GET'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 120
    }

    // Simple load balancing settings
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 2
      additionalLatencyInMilliseconds: 0
    }
  }
}

// Origin inside the origin group
resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2023-05-01' = {
  parent: originGroup
  name: originName
  properties: {
    hostName: appServiceHostName
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true

    httpPort: 80
    httpsPort: 443

    // If пусто empty – hostName is taken
    originHostHeader: appServiceHostName

    // Load balancing priority & weight
    priority: 1      // 1–5
    weight: 1000     // 1–1000
  }
}

output originGroupId string = originGroup.id
output originId      string = origin.id

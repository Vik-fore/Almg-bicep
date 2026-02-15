
@description('Existing Front Door profile name')
param frontdoorProfileName string

@description('Existing endpoint name')
param endpointName string

@description('Name of the route')
param routeName string = 'rt-alm-chatbot-prod'

@description('Origin group resource ID')
param originGroupId string

@description('Array of custom domain resource IDs (Front Door domains)')
param customDomainIds array

// Existing Front Door Standard profile
resource fdProfile 'Microsoft.Cdn/profiles@2023-05-01' existing = {
  name: frontdoorProfileName
}

// Existing AFD endpoint
resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' existing = {
  parent: fdProfile
  name: endpointName
}

// Route for Azure Front Door Standard
resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2023-05-01' = {
  parent: endpoint
  name: routeName
  properties: {
    // Enable route
    enabledState: 'Enabled'

    // Redirect HTTP → HTTPS
    httpsRedirect: 'Enabled'

    // Forward to backend using same protocol as client request
    forwardingProtocol: 'MatchRequest'

    // Supported protocols from client side
    supportedProtocols: [
      'Http'
      'Https'
    ]

    // Match all paths
    patternsToMatch: [
      '/*'
    ]

    // Attach origin group
    originGroup: {
      id: originGroupId
    }

    // Attach custom domains (FD endpoint or custom domain IDs)
    customDomains: [
      for d in customDomainIds: {
        id: d
      }
    ]

    // Link also to the default endpoint domain
    linkToDefaultDomain: 'Enabled'
  }
}

output routeId string = route.id

targetScope = 'resourceGroup'

@description('Existing Front Door profile name')
param frontdoorProfileName string

@description('AFD endpoint name')
param endpointName string

resource fdProfile 'Microsoft.Cdn/profiles@2023-05-01' existing = {
  name: frontdoorProfileName
}

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' = {
  parent: fdProfile
  name: endpointName
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

output endpointId string = endpoint.id
output endpointHostName string = endpoint.properties.hostName

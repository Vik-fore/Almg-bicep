targetScope = 'resourceGroup'

@description('Workload name (CAF-like)')
param workloadName string = 'almchatbot'

@description('Environment name')
param environment string = 'prod'

@description('Region short name')
param regionShort string = 'weu'

// Existing names in PROD
var frontDoorProfileName = 'afd-${workloadName}-${environment}-${regionShort}'
var endpointName1 = 'ep-${workloadName}-${environment}-${regionShort}'
var routeName1 = 'rt-${workloadName}-${environment}-${regionShort}'
var originGroupName = 'og-${workloadName}-${environment}-${regionShort}'

// Existing AFD profile
resource afdProfile 'Microsoft.Cdn/profiles@2023-05-01' existing = {
  name: frontDoorProfileName
}

// Existing endpoint #1
resource afdEndpoint1 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' existing = {
  parent: afdProfile
  name: endpointName1
}

// Existing route #1 (если реально существует)
resource route1 'Microsoft.Cdn/profiles/afdEndpoints/routes@2023-05-01' existing = {
  parent: afdEndpoint1
  name: routeName1
}

// Existing origin group
resource originGroup 'Microsoft.Cdn/profiles/originGroups@2023-05-01' existing = {
  parent: afdProfile
  name: originGroupName
}

output profileId string = afdProfile.id
output endpoint1Id string = afdEndpoint1.id
output endpoint1HostName string = afdEndpoint1.properties.hostName
output route1Id string = route1.id
output originGroupId string = originGroup.id

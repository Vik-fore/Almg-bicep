targetScope = 'resourceGroup'

@description('Workload name (CAF-like)')
param workloadName string = 'almchatbot'

@description('Environment name')
param environment string = 'prod'

@description('Region short name')
param regionShort string = 'weu'

@description('Backend host name of App Service (without https://)')
param appServiceHostName string

var wafPolicyName = 'waf-${workloadName}-${environment}-${regionShort}'
var frontDoorProfileName = 'afd-${workloadName}-${environment}-${regionShort}'
var endpointName = 'ep-${workloadName}-${environment}-${regionShort}'
var originGroupName = 'og-${workloadName}-${environment}-${regionShort}'
var originName = 'orig-${workloadName}-${environment}-${regionShort}-app'
var routeName = 'rt-${workloadName}-${environment}-${regionShort}'
var securityPolicyName = 'sp-${workloadName}-${environment}-${regionShort}'

// 1) WAF policy
module waf './modules/security/waf.bicep' = {
  name: 'deploy-waf'
  params: {
    wafPolicyName: wafPolicyName
  }
}

// 2) Front Door profile (Standard)
module frontdoor './modules/security/frontdoor.bicep' = {
  name: 'deploy-frontdoor-profile'
  params: {
    frontDoorName: frontDoorProfileName
    location: 'global'
  }
}

// 3) Endpoint (child of profile)
module endpoint './modules/security/frontdoor_endpoint.bicep' = {
  name: 'deploy-frontdoor-endpoint'
  params: {
    frontdoorProfileName: frontDoorProfileName
    endpointName: endpointName
  }
}

// 4) Origins (origin group + origin -> App Service)
module origins './modules/security/frontdoor_origins.bicep' = {
  name: 'deploy-frontdoor-origins'
  params: {
    frontdoorProfileName: frontDoorProfileName
    originGroupName: originGroupName
    originName: originName
    appServiceHostName: appServiceHostName
  }
}

// 5) Route
module routes './modules/security/frontdoor_routes.bicep' = {
  name: 'deploy-frontdoor-routes'
  params: {
    frontdoorProfileName: frontDoorProfileName
    endpointName: endpointName
    routeName: routeName
    originGroupId: origins.outputs.originGroupId
    customDomainIds: []
  }
}

// 6) Attach WAF to endpoint (security policy)
module wafAssociation './modules/security/frontdoor_securityPolicy_waf.bicep' = {
  name: 'deploy-frontdoor-waf-association'
  params: {
    frontdoorProfileName: frontDoorProfileName
    securityPolicyName: securityPolicyName
    wafPolicyId: waf.outputs.wafPolicyId
    endpointId: endpoint.outputs.endpointId
  }
}

output afdProfileName string = frontDoorProfileName
output afdEndpointHostName string = endpoint.outputs.endpointHostName
output wafPolicyId string = waf.outputs.wafPolicyId
output wafAssociationId string = wafAssociation.outputs.securityPolicyId

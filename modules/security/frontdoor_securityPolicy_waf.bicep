@description('Existing Front Door profile name')
param frontdoorProfileName string

@description('Security policy name')
param securityPolicyName string

@description('WAF policy resource ID (Microsoft.Network/FrontDoorWebApplicationFirewallPolicies)')
param wafPolicyId string

@description('Front Door endpoint resource ID (Microsoft.Cdn/profiles/afdEndpoints)')
param endpointId string

resource fdProfile 'Microsoft.Cdn/profiles@2023-05-01' existing = {
  name: frontdoorProfileName
}

resource securityPolicy 'Microsoft.Cdn/profiles/securityPolicies@2023-05-01' = {
  parent: fdProfile
  name: securityPolicyName
  properties: {
    parameters: {
      type: 'WebApplicationFirewall'
      wafPolicy: {
        id: wafPolicyId
      }
      associations: [
        {
          domains: [
            {
              id: endpointId
            }
          ]
          patternsToMatch: [
            '/*'
          ]
        }
      ]
    }
  }
}

output securityPolicyId string = securityPolicy.id

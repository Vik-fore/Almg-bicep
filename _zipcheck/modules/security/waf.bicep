@description('Name of the WAF policy')
param wafPolicyName string

@description('WAF mode: Detection or Prevention')
@allowed([
  'Detection'
  'Prevention'
])
param mode string = 'Prevention'

resource wafPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2020-11-01' = {
  name: wafPolicyName
  location: 'global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: mode
    }

    // IMPORTANT:
    // In your environment Standard_AzureFrontDoor does NOT support managedRules.
    // We deploy the policy without managed rules to unblock Front Door deployment.
  }
}

output wafPolicyId string = wafPolicy.id

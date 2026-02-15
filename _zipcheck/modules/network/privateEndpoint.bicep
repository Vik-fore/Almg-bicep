@description('Name of the Private Endpoint')
param privateEndpointName string

@description('Location of the Private Endpoint')
param location string = 'westeurope'

@description('Subnet resource ID where the Private Endpoint will be deployed')
param privateSubnetId string

@description('The resource ID of the target service (e.g. Key Vault, SQL, Storage)')
param privateLinkServiceId string

@description('The subresource for the Private Link service (e.g. vault, sqlServer, blob, table)')
param subresourceName string

// Private Endpoint resource
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: privateSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${privateEndpointName}-connection'
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: [
            subresourceName
          ]
          requestMessage: 'Private Endpoint connection request'
        }
      }
    ]
  }
}

// Output Private Endpoint ID
output privateEndpointId string = privateEndpoint.id

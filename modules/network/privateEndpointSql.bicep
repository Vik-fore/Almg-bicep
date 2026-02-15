targetScope = 'resourceGroup'

@description('Name of the Private Endpoint resource.')
param privateEndpointName string

@description('Azure region where the Private Endpoint will be deployed (e.g. westeurope).')
param location string

@description('Resource ID of the subnet where the Private Endpoint NIC will be created.')
param subnetId string

@description('Resource ID of the SQL Server (Microsoft.Sql/servers) to connect via Private Link.')
param sqlServerId string

@description('Name of the Private Link connection inside the Private Endpoint.')
param privateLinkConnectionName string = 'sql-connection'

// ------------------------------------------------------------
// Private Endpoint to Azure SQL Server
// This creates a NIC inside your subnet and connects it to the SQL Server privately.
// ------------------------------------------------------------
resource sqlPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }

    // Private Link connection to SQL Server
    privateLinkServiceConnections: [
      {
        name: privateLinkConnectionName
        properties: {
          privateLinkServiceId: sqlServerId

          // SQL Server Private Link groupId is "sqlServer"
          groupIds: [
            'sqlServer'
          ]

          requestMessage: 'Private Endpoint for Azure SQL Server'
        }
      }
    ]
  }
}

output privateEndpointId string = sqlPrivateEndpoint.id
output privateEndpointNameOut string = sqlPrivateEndpoint.name

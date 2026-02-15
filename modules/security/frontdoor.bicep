targetScope = 'resourceGroup'

@description('Name of the Front Door profile (AFD Standard/Premium)')
param frontDoorName string = 'afd-alm-chatbot-prod'

@description('Location for Front Door resources. Must be global.')
param location string = 'global'

resource frontDoor 'Microsoft.Cdn/profiles@2023-05-01' = {
  name: frontDoorName
  location: location
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
}

output frontDoorId string = frontDoor.id
output frontDoorNameOut string = frontDoor.name

@description('Name of the Front Door profile')
param frontDoorName string = 'afd-alm-chatbot-prod'

@description('Azure region for Front Door Manager (always Global)')
param location string = 'global'

resource frontDoor 'Microsoft.Cdn/profiles@2023-05-01' = {
  name: frontDoorName
  location: location
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
}

output frontDoorId string = frontDoor.id

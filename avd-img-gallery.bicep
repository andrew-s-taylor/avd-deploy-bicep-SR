param azureSubscriptionID string
param sigName string
param sigLocation string
param imagePublisher string
param imageDefinitionName string
param imageOffer string
param imageSKU string
param imageLocation string
param roleNameGalleryImage string
param templateImageResourceGroup string
param useridentity string
param resourcegroupimg string

var templateImageResourceGroupId = '/subscriptions/${azureSubscriptionID}/resourcegroups/${templateImageResourceGroup}'
var imageDefinitionFullName = '${sigName}/${imageDefinitionName}'

//Create Shared Image Gallery
resource avdsig 'Microsoft.Compute/galleries@2020-09-30' = {
  name: sigName
  location: sigLocation
}

//Create Image definition
resource avdid 'Microsoft.Compute/galleries/images@2020-09-30' = {
  name: imageDefinitionFullName
  location: sigLocation
  properties: {
    osState: 'Generalized'
    osType: 'Windows'
    identifier: {
      publisher: imagePublisher
      offer: imageOffer
      sku: imageSKU
    }
  }
  dependsOn: [
    avdsig
  ]
}






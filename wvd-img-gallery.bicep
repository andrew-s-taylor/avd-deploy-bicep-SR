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

//Create Shard Image Gallery
resource wvdsig 'Microsoft.Compute/galleries@2020-09-30' = {
  name: sigName
  location: sigLocation
}

//Create Image definitation
resource wvdid 'Microsoft.Compute/galleries/images@2020-09-30' = {
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
    wvdsig
  ]
}

//Create Identity
resource wvdidentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: useridentity
  tags: {}
  location: sigLocation
}


var roleid = guid(useridentity)
//create role definition

resource gallerydef 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' = {
  name: guid(roleNameGalleryImage)
  properties: {
    roleName: roleNameGalleryImage
    description: 'Custom WVD Image Gallery Role'
    permissions: [
      {
        actions: [
          'Microsoft.Compute/galleries/read'
          'Microsoft.Compute/galleries/images/read'
          'Microsoft.Compute/galleries/images/versions/read'
          'Microsoft.Compute/galleries/images/versions/write'
          'Microsoft.Compute/images/write'
          'Microsoft.Compute/images/read'
          'Microsoft.Compute/images/delete'
        ]
      }
    ]
    assignableScopes: [
      resourcegroupimg
    ]
  }
}

var galleryname = guid(templateImageResourceGroup)
resource galleryassign 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
    name: galleryname
    properties: {
      roleDefinitionId: gallerydef.id
      principalId: roleid
    }
  }




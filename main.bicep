targetScope = 'subscription'

//Define WVD deployment parameters
param resourceGroupPrefix string = 'RG-WVD-BICEP-WVD-'
param hostpoolName string = 'myWVDHostpool'
param hostpoolFriendlyName string = 'My Bicep deployed Hostpool'
param appgroupName string = 'myWVDAppGroup'
param appgroupNameFriendlyName string = 'My Bicep deployed Appgroup'
param workspaceName string = 'myWVDWorkspace'
param workspaceNameFriendlyName string = 'My Bicep deployed Workspace'
param preferredAppGroupType string = 'Desktop'
param wvdbackplanelocation string = 'eastus'
param hostPoolType string = 'pooled'
param loadBalancerType string = 'BreadthFirst'
param logAnalyticsWorkspaceName string = 'myWVDLAWorkspace'
param automationaccountname string = 'account'
param logAnalyticslocation string = 'ukwest'
param validationname string = '${hostpoolName}validation'

//Define Image Gallery Parameters
param sigName string = 'mywvdgallery'
param sigLocation string = 'uksouth'
param imagePublisher string = 'microsoftwindowsdesktop'
param imageDefinitionName string = 'mywvdimage'
param imageOffer string = 'office-365'
param imageSKU string = 'office-36520h1-evd-o365pp'
param imageLocation string = 'uksouth'
param roleNameGalleryImage string = 'wvdimagemanager'
param templateImageResourceGroup string = 'rgimg'
param azureSubscriptionID string = 'subscription'
param useridentity string = 'identitymanager'

//Define Networking deployment parameters
param vnetName string = 'wvd-vnet'
param vnetaddressPrefix string = '10.0.0.0/15'
param subnetPrefix string = '10.0.1.0/24'
param vnetLocation string = 'uksouth'
param subnetName string = 'wvd-subnet'

//Define Azure Files deployment parameters
param storageaccountlocation string = 'uksouth'
param storageaccountName string = 'wvdsa'
param storageaccountkind string = 'FileStorage'
param storgeaccountglobalRedundancy string = 'Premium_LRS'
param fileshareFolderName string = 'profilecontainers'
param storageaccountkindblob string = 'BlobStorage'

//Create Resource Groups
resource rgwvd 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: '${resourceGroupPrefix}BACKPLANE'
  location: 'uksouth'
}
resource rgnetw 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: '${resourceGroupPrefix}NETWORK'
  location: 'uksouth'
}
resource rgfs 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: '${resourceGroupPrefix}FILESERVICES'
  location: 'uksouth'
}
resource rdmon 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: '${resourceGroupPrefix}MONITOR'
  location: 'uksouth'
}
resource rgimg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: '${resourceGroupPrefix}IMG'
  location: 'uksouth'
}
resource rgbackup 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: '${resourceGroupPrefix}BACKUP'
  location: 'uksouth'
}

//Create WVD backplane objects and configure Log Analytics Diagnostics Settings
module wvdbackplane './wvd-backplane-module.bicep' = {
  name: 'wvdbackplane'
  scope: rgwvd
  params: {
    hostpoolName: hostpoolName
    hostpoolFriendlyName: hostpoolFriendlyName
    appgroupName: appgroupName
    appgroupNameFriendlyName: appgroupNameFriendlyName
    workspaceName: workspaceName
    workspaceNameFriendlyName: workspaceNameFriendlyName
    preferredAppGroupType: preferredAppGroupType
    applicationgrouptype: preferredAppGroupType
    wvdbackplanelocation: wvdbackplanelocation
    hostPoolType: hostPoolType
    loadBalancerType: loadBalancerType
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    logAnalyticsResourceGroup: rdmon.name
    wvdBackplaneResourceGroup: rgwvd.name
    logAnalyticslocation: logAnalyticslocation
    automationaccountname: automationaccountname
    validationname: validationname
  }
}


//Create Image Gallery and image

module wvdimg './wvd-img-gallery.bicep' = {
  name: 'wvdimg'
  scope: rgimg
  params: {
    azureSubscriptionID: azureSubscriptionID
    sigName: sigName
    sigLocation: sigLocation
    imagePublisher: imagePublisher
    imageDefinitionName: imageDefinitionName
    imageOffer:imageOffer
    imageSKU: imageSKU
    imageLocation: imageLocation
    roleNameGalleryImage: roleNameGalleryImage
    templateImageResourceGroup: templateImageResourceGroup
    useridentity: useridentity
    resourcegroupimg: rgimg.id
  }
}

//Create WVD Network and Subnet
module wvdnetwork './wvd-network-module.bicep' = {
  name: 'wvdnetwork'
  scope: rgnetw
  params: {
    vnetName: vnetName
    vnetaddressPrefix: vnetaddressPrefix
    subnetPrefix: subnetPrefix
    vnetLocation: vnetLocation
    subnetName: subnetName
  }
}

//Create WVD Azure File Services and FileShare`
module wvdFileServices './wvd-fileservices-module.bicep' = {
  name: 'wvdFileServices'
  scope: rgfs
  params: {
    storageaccountlocation: storageaccountlocation
    storageaccountName: storageaccountName
    storageaccountkind: storageaccountkind
    storgeaccountglobalRedundancy: storgeaccountglobalRedundancy
    fileshareFolderName: fileshareFolderName
    storageaccountkindblob: storageaccountkindblob
  }
}

//Create Private Endpoint for file storage
module pep './wvd-fileservices-privateendpoint-module.bicep' = {
  name: 'privateEndpoint'
  scope: rgnetw
  params: {
    location: vnetLocation
    privateEndpointName: 'pep-sto'
    storageAccountId: wvdFileServices.outputs.storageAccountId
    vnetId: wvdnetwork.outputs.vnetId
    subnetId: wvdnetwork.outputs.subnetId
  }
}




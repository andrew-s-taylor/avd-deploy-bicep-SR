//Define Azure Files parmeters
param storageaccountlocation string = 'westeurope'
param storageaccountName string
param storageaccountkind string
param storgeaccountglobalRedundancy string = 'Premium_LRS'
param fileshareFolderName string = 'profilecontainers'
param storageaccountkindblob string

// Create Storage account
resource sa 'Microsoft.Storage/storageAccounts@2020-08-01-preview' = {
  name: storageaccountName
  location: storageaccountlocation
  kind: storageaccountkind
  sku: {
    name: storgeaccountglobalRedundancy
  }
}

// Concat FileShare
var filesharelocation = '${sa.name}/default/${fileshareFolderName}'

// Create FileShare
resource fs 'Microsoft.Storage/storageAccounts/fileServices/shares@2020-08-01-preview' = {
  name: filesharelocation
}

//Create Scripts Blob

// Concat FileShare
var storageaccount2 = '${storageaccountName}blob'
// Create Storage account
resource sablob 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageaccount2
  location: storageaccountlocation
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'BlobStorage'
  properties: {
    accessTier: 'Hot'
  }
}

// Concat FileShare
var filesharelocationblob = '${sablob.name}/default/${fileshareFolderName}blob'
resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: filesharelocationblob
  properties: {
  publicAccess: 'Container'
  }
}
output storageAccountId string = sa.id

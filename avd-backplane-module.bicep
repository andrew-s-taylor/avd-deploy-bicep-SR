//Define WVD deployment parameters
param hostpoolName string
param hostpoolFriendlyName string
param appgroupName string
param appgroupNameFriendlyName string
param workspaceName string
param workspaceNameFriendlyName string
param applicationgrouptype string = 'Desktop'
param preferredAppGroupType string = 'Desktop'
param avdbackplanelocation string = 'eastus'
param hostPoolType string = 'pooled'
param loadBalancerType string = 'BreadthFirst'
param logAnalyticsWorkspaceName string
param logAnalyticslocation string = 'westeurope'
param logAnalyticsWorkspaceSku string = 'pergb2018'
param logAnalyticsResourceGroup string
param avdBackplaneResourceGroup string
param automationaccountname string = 'account'
param validationname string

param appgroupNamevalid string = '${appgroupName}validation'
param appgroupNameFriendlyNamevalid string = '${appgroupNameFriendlyName}validation'
param workspaceNamevalid string = '${workspaceName}validation'
param workspaceNameFriendlyNamevalid string = '${workspaceNameFriendlyName}validation'

//Create AVD Hostpool
resource hp 'Microsoft.DesktopVirtualization/hostpools@2019-12-10-preview' = {
  name: hostpoolName
  location: avdbackplanelocation
  properties: {
    friendlyName: hostpoolFriendlyName
    hostPoolType: hostPoolType
    loadBalancerType: loadBalancerType
    preferredAppGroupType: preferredAppGroupType
  }
}

//Create AVD Hostpool Validation
resource hpvalid 'Microsoft.DesktopVirtualization/hostpools@2019-12-10-preview' = {
  name: validationname
  location: avdbackplanelocation
  properties: {
    friendlyName: hostpoolFriendlyName
    hostPoolType: hostPoolType
    loadBalancerType: loadBalancerType
    preferredAppGroupType: preferredAppGroupType
  }
}

//Create AVD AppGroup
resource ag 'Microsoft.DesktopVirtualization/applicationgroups@2019-12-10-preview' = {
  name: appgroupName
  location: avdbackplanelocation
  properties: {
    friendlyName: appgroupNameFriendlyName
    applicationGroupType: applicationgrouptype
    hostPoolArmPath: hp.id
  }
}

//Create AVD AppGroup Validation
resource agvalid 'Microsoft.DesktopVirtualization/applicationgroups@2019-12-10-preview' = {
  name: appgroupNamevalid
  location: avdbackplanelocation
  properties: {
    friendlyName: appgroupNameFriendlyNamevalid
    applicationGroupType: applicationgrouptype
    hostPoolArmPath: hp.id
  }
}

//Create AVD Workspace
resource ws 'Microsoft.DesktopVirtualization/workspaces@2019-12-10-preview' = {
  name: workspaceName
  location: avdbackplanelocation
  properties: {
    friendlyName: workspaceNameFriendlyName
    applicationGroupReferences: [
      ag.id
    ]
  }
}

//Create AVD Workspace Wavlidation
resource wsvalid 'Microsoft.DesktopVirtualization/workspaces@2019-12-10-preview' = {
  name: workspaceNamevalid
  location: avdbackplanelocation
  properties: {
    friendlyName: workspaceNameFriendlyNamevalid
    applicationGroupReferences: [
      ag.id
    ]
  }
}

//Create Azure Log Analytics Workspace
module wvdmonitor './avd-LogAnalytics.bicep' = {
  name: 'LAWorkspace'
  scope: resourceGroup(logAnalyticsResourceGroup)
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    logAnalyticslocation: logAnalyticslocation
    logAnalyticsWorkspaceSku: logAnalyticsWorkspaceSku
    hostpoolName: hp.name
    workspaceName: ws.name
    logAnalyticsResourceGroup: logAnalyticsResourceGroup
    avdBackplaneResourceGroup: avdBackplaneResourceGroup
    automationaccountname: automationaccountname
  }
}

//Define Log Analytics parameters
param logAnalyticsWorkspaceName string
param logAnalyticslocation string = 'uksouth'
param logAnalyticsWorkspaceSku string = 'pergb2018'
param hostpoolName string
param workspaceName string
param logAnalyticsResourceGroup string
param wvdBackplaneResourceGroup string
param automationaccountname string

//Create Log Analytics Workspace
resource wvdla 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: logAnalyticsWorkspaceName
  location: logAnalyticslocation
  properties: {
    sku: {
      name: logAnalyticsWorkspaceSku
    }
  }
}

//Create Diagnotic Setting for WVD components
module wvdmonitor './wvd-monitor-diag.bicep' = {
  name: 'myBicepLADiag'
  scope: resourceGroup(wvdBackplaneResourceGroup)
  params: {
    logAnalyticsWorkspaceID: wvdla.id
    hostpoolName: hostpoolName
    workspaceName: workspaceName
  }
}

//Create Automation Account
resource automation_account 'Microsoft.Automation/automationAccounts@2015-10-31' = {
  location: logAnalyticslocation
  name: automationaccountname
  properties: {
    sku: {
      name: 'Basic'
    }
  }
}


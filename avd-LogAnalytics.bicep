//Define Log Analytics parameters
param logAnalyticsWorkspaceName string
param logAnalyticslocation string = 'uksouth'
param logAnalyticsWorkspaceSku string = 'pergb2018'
param hostpoolName string
param workspaceName string
param logAnalyticsResourceGroup string
param avdBackplaneResourceGroup string
param automationaccountname string

//Create Log Analytics Workspace
resource avdla 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: logAnalyticsWorkspaceName
  location: logAnalyticslocation
  properties: {
    sku: {
      name: logAnalyticsWorkspaceSku
    }
  }
}

//Create Diagnotic Setting for WVD components
module avdmonitor './avd-monitor-diag.bicep' = {
  name: 'myBicepLADiag'
  scope: resourceGroup(avdBackplaneResourceGroup)
  params: {
    logAnalyticsWorkspaceID: avdla.id
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


param name string
param location string
param tags object = {}
param publicNetworkAccess string
param logAnalyticsWorkspaceResourceId string
param workloadProfileName string
param workloadProfileType string
param workloadProfileMinCount int = 1
param workloadProfileMaxCount int = 1

module environment 'br/public:avm/res/app/managed-environment:0.13.1' = {
  name: 'deploy-container-apps-environment'
  params: {
    name: name
    location: location
    tags: tags
    zoneRedundant: false
    publicNetworkAccess: publicNetworkAccess
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    }
    workloadProfiles: [
      {
        name: workloadProfileName
        workloadProfileType: workloadProfileType
        minimumCount: workloadProfileMinCount
        maximumCount: workloadProfileMaxCount
      }
    ]
    enableTelemetry: false
  }
}

output resourceId string = environment.outputs.resourceId
output resourceName string = environment.outputs.name
output defaultDomain string = environment.outputs.defaultDomain
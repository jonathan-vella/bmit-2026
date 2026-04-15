@description('App Service Plan name.')
param name string

@description('Azure region.')
param location string

@description('Resource tags.')
param tags object = {}

@description('Log Analytics workspace resource ID for diagnostics.')
param logAnalyticsWorkspaceResourceId string

@description('App Service Plan SKU name.')
param skuName string = 'S1'

module plan 'br/public:avm/res/web/serverfarm:0.4.0' = {
  name: 'deploy-app-service-plan'
  params: {
    name: name
    location: location
    tags: tags
    kind: 'linux'
    reserved: true
    skuName: skuName
    skuCapacity: 1
    zoneRedundant: false
    diagnosticSettings: [
      {
        name: 'send-to-law'
        workspaceResourceId: logAnalyticsWorkspaceResourceId
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
      }
    ]
    enableTelemetry: false
  }
}

output resourceId string = plan.outputs.resourceId
output resourceName string = plan.outputs.name

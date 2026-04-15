param name string
param location string
param tags object = {}

module workspace 'br/public:avm/res/operational-insights/workspace:0.15.0' = {
  name: 'deploy-workspace'
  params: {
    name: name
    location: location
    tags: tags
    skuName: 'PerGB2018'
    dataRetention: 30
    dailyQuotaGb: '5'
    features: {
      disableLocalAuth: true
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    diagnosticSettings: [
      {
        name: 'send-to-self'
        useThisWorkspace: true
        logCategoriesAndGroups: [
          {
            categoryGroup: 'allLogs'
          }
        ]
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

output resourceId string = workspace.outputs.resourceId
output resourceName string = workspace.outputs.name
output workspaceId string = workspace.outputs.logAnalyticsWorkspaceId
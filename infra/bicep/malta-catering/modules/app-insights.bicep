param name string
param location string
param tags object = {}
param workspaceResourceId string

module component 'br/public:avm/res/insights/component:0.7.1' = {
  name: 'deploy-component'
  params: {
    name: name
    location: location
    tags: tags
    workspaceResourceId: workspaceResourceId
    applicationType: 'web'
    kind: 'web'
    ingestionMode: 'LogAnalytics'
    disableIpMasking: false
    retentionInDays: 90
    diagnosticSettings: [
      {
        name: 'send-to-law'
        workspaceResourceId: workspaceResourceId
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

output resourceId string = component.outputs.resourceId
output resourceName string = component.outputs.name
output connectionString string = component.outputs.connectionString
output instrumentationKey string = component.outputs.instrumentationKey
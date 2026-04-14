param name string
param location string
param tags object = {}
param logAnalyticsWorkspaceResourceId string

module registry 'br/public:avm/res/container-registry/registry:0.12.1' = {
  name: 'deploy-container-registry'
  params: {
    name: name
    location: location
    tags: tags
    acrSku: 'Basic'
    acrAdminUserEnabled: false
    zoneRedundancy: 'Disabled'
    diagnosticSettings: [
      {
        name: 'send-to-law'
        workspaceResourceId: logAnalyticsWorkspaceResourceId
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

output resourceId string = registry.outputs.resourceId
output resourceName string = registry.outputs.name
output loginServer string = registry.outputs.loginServer
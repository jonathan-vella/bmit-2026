param name string
param location string
param tags object = {}
param logAnalyticsWorkspaceResourceId string

@description('Subnet resource ID for the private endpoint.')
param privateEndpointSubnetResourceId string

@description('Private DNS zone resource ID for ACR.')
param privateDnsZoneResourceId string

module registry 'br/public:avm/res/container-registry/registry:0.12.1' = {
  name: 'deploy-container-registry'
  params: {
    name: name
    location: location
    tags: tags
    acrSku: 'Premium'
    acrAdminUserEnabled: false
    zoneRedundancy: 'Disabled'
    publicNetworkAccess: 'Disabled'
    networkRuleBypassOptions: 'AzureServices'
    azureADAuthenticationAsArmPolicyStatus: 'enabled'
    privateEndpoints: [
      {
        subnetResourceId: privateEndpointSubnetResourceId
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: privateDnsZoneResourceId
            }
          ]
        }
      }
    ]
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

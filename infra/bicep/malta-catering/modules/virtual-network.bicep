@description('Virtual network name.')
param name string

@description('Azure region.')
param location string

@description('Resource tags.')
param tags object = {}

@description('Log Analytics workspace resource ID for diagnostics.')
param logAnalyticsWorkspaceResourceId string

@description('VNet address prefix (CIDR).')
param addressPrefix string = '10.0.0.0/24'

@description('App Service integration subnet prefix.')
param appServiceSubnetPrefix string = '10.0.0.0/27'

@description('Private endpoints subnet prefix.')
param privateEndpointsSubnetPrefix string = '10.0.0.32/27'

module vnet 'br/public:avm/res/network/virtual-network:0.7.0' = {
  name: 'deploy-virtual-network'
  params: {
    name: name
    location: location
    tags: tags
    addressPrefixes: [
      addressPrefix
    ]
    subnets: [
      {
        name: 'snet-app-service'
        addressPrefix: appServiceSubnetPrefix
        delegation: 'Microsoft.Web/serverFarms'
      }
      {
        name: 'snet-private-endpoints'
        addressPrefix: privateEndpointsSubnetPrefix
      }
    ]
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

output resourceId string = vnet.outputs.resourceId
output resourceName string = vnet.outputs.name
output appServiceSubnetResourceId string = vnet.outputs.subnetResourceIds[0]
output privateEndpointsSubnetResourceId string = vnet.outputs.subnetResourceIds[1]

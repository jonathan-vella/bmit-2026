param name string
param location string
param tags object = {}
param logAnalyticsWorkspaceResourceId string

@description('Subnet resource ID for the private endpoint.')
param privateEndpointSubnetResourceId string

@description('Private DNS zone resource ID for Table Storage.')
param privateDnsZoneResourceId string

module storageAccount 'br/public:avm/res/storage/storage-account:0.32.0' = {
  name: 'deploy-storage-account'
  params: {
    name: name
    location: location
    tags: tags
    kind: 'StorageV2'
    skuName: 'Standard_LRS'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    defaultToOAuthAuthentication: true
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    privateEndpoints: [
      {
        service: 'table'
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
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
      }
    ]
    tableServices: {
      tables: [
        {
          name: 'orders'
        }
        {
          name: 'menu'
        }
        {
          name: 'customers'
        }
      ]
      diagnosticSettings: [
        {
          name: 'table-service-to-law'
          workspaceResourceId: logAnalyticsWorkspaceResourceId
          metricCategories: [
            {
              category: 'AllMetrics'
            }
          ]
        }
      ]
    }
    enableTelemetry: false
  }
}

output resourceId string = storageAccount.outputs.resourceId
output resourceName string = storageAccount.outputs.name
output primaryBlobEndpoint string = storageAccount.outputs.primaryBlobEndpoint

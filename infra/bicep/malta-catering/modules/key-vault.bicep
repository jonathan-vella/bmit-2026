param name string
param location string
param tags object = {}
param logAnalyticsWorkspaceResourceId string

@description('Subnet resource ID for the private endpoint.')
param privateEndpointSubnetResourceId string

@description('Private DNS zone resource ID for Key Vault.')
param privateDnsZoneResourceId string

@secure()
param appInsightsConnectionString string

module vault 'br/public:avm/res/key-vault/vault:0.13.3' = {
  name: 'deploy-key-vault'
  params: {
    name: name
    location: location
    tags: tags
    sku: 'standard'
    enableRbacAuthorization: true
    enablePurgeProtection: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enableVaultForDeployment: false
    enableVaultForDiskEncryption: false
    enableVaultForTemplateDeployment: false
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
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
    secrets: [
      {
        name: 'appinsights-connection-string'
        value: appInsightsConnectionString
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

output resourceId string = vault.outputs.resourceId
output resourceName string = vault.outputs.name
output uri string = vault.outputs.uri

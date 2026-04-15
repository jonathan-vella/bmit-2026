@description('Web App name.')
param name string

@description('Azure region.')
param location string

@description('Resource tags.')
param tags object = {}

@description('App Service Plan resource ID.')
param serverFarmResourceId string

@description('Subnet resource ID for VNet integration.')
param virtualNetworkSubnetId string

@description('Key Vault name for existing resource reference.')
param keyVaultName string

@description('Key Vault URI.')
param keyVaultUri string

@description('Storage account name for existing resource reference.')
param storageAccountName string

@description('Container registry name for existing resource reference.')
param containerRegistryName string

@description('Container registry login server FQDN.')
param registryLoginServer string

@description('Log Analytics workspace resource ID for diagnostics.')
param logAnalyticsWorkspaceResourceId string

@description('Container image name.')
param containerImageName string

@description('Container image tag.')
param containerImageTag string = 'latest'

@description('Enable staging deployment slot.')
param enableStagingSlot bool = true

var keyVaultSecretsUserRoleDefinitionId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '4633458b-17de-408a-b874-0445c86b69e6'
)
var storageTableContributorRoleDefinitionId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
)
var acrPullRoleDefinitionId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '7f951dda-4ed3-4680-a7ca-43fe172d538d'
)

module site 'br/public:avm/res/web/site:0.15.0' = {
  name: 'deploy-web-app'
  params: {
    name: name
    location: location
    tags: tags
    kind: 'app,linux,container'
    serverFarmResourceId: serverFarmResourceId
    managedIdentities: {
      systemAssigned: true
    }
    httpsOnly: true
    virtualNetworkSubnetId: virtualNetworkSubnetId
    vnetRouteAllEnabled: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${registryLoginServer}/${containerImageName}:${containerImageTag}'
      acrUseManagedIdentityCreds: true
      http20Enabled: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      alwaysOn: true
    }
    appSettingsKeyValuePairs: {
      APPLICATIONINSIGHTS_CONNECTION_STRING: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=appinsights-connection-string)'
      AZURE_STORAGE_ACCOUNT_NAME: storageAccountName
      AZURE_KEYVAULT_URI: keyVaultUri
      DOCKER_REGISTRY_SERVER_URL: 'https://${registryLoginServer}'
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
    }
    slots: enableStagingSlot
      ? [
          {
            name: 'staging'
            managedIdentities: {
              systemAssigned: true
            }
            siteConfig: {
              linuxFxVersion: 'DOCKER|${registryLoginServer}/${containerImageName}:${containerImageTag}'
              acrUseManagedIdentityCreds: true
              http20Enabled: true
              minTlsVersion: '1.2'
              ftpsState: 'Disabled'
              alwaysOn: true
            }
            appSettingsKeyValuePairs: {
              APPLICATIONINSIGHTS_CONNECTION_STRING: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=appinsights-connection-string)'
              AZURE_STORAGE_ACCOUNT_NAME: storageAccountName
              AZURE_KEYVAULT_URI: keyVaultUri
              DOCKER_REGISTRY_SERVER_URL: 'https://${registryLoginServer}'
              WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
            }
          }
        ]
      : []
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

// RBAC role assignments for the web app's system-assigned managed identity

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' existing = {
  name: keyVaultName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
  name: storageAccountName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2025-06-01-preview' existing = {
  name: containerRegistryName
}

resource keyVaultSecretsUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, name, 'kv-secrets-user')
  scope: keyVault
  properties: {
    roleDefinitionId: keyVaultSecretsUserRoleDefinitionId
    principalId: site.outputs.systemAssignedMIPrincipalId!
    principalType: 'ServicePrincipal'
  }
}

resource storageTableContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, name, 'storage-table-contributor')
  scope: storageAccount
  properties: {
    roleDefinitionId: storageTableContributorRoleDefinitionId
    principalId: site.outputs.systemAssignedMIPrincipalId!
    principalType: 'ServicePrincipal'
  }
}

resource acrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, name, 'acr-pull')
  scope: containerRegistry
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: site.outputs.systemAssignedMIPrincipalId!
    principalType: 'ServicePrincipal'
  }
}

output resourceId string = site.outputs.resourceId
output resourceName string = site.outputs.name
output defaultHostname string = site.outputs.defaultHostname
output principalId string = site.outputs.systemAssignedMIPrincipalId!

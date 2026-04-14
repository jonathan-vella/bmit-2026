param name string
param location string
param tags object = {}
param environmentResourceId string
param workloadProfileName string
param keyVaultName string
param keyVaultUri string
param storageAccountName string
param containerRegistryName string
param registryLoginServer string
param logAnalyticsWorkspaceResourceId string
param containerImageName string
param containerImageTag string

var appInsightsSecretName = 'appinsights-connection-string'
var appInsightsSecretUrl = '${keyVaultUri}secrets/${appInsightsSecretName}'
var keyVaultSecretsUserRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
var storageTableContributorRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3')
var acrPullRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
var containerCpu = json('0.25')

module app 'br/public:avm/res/app/container-app:0.22.0' = {
  name: 'deploy-container-app'
  params: {
    name: name
    location: location
    tags: tags
    environmentResourceId: environmentResourceId
    workloadProfileName: workloadProfileName
    managedIdentities: {
      systemAssigned: true
    }
    activeRevisionsMode: 'Single'
    ingressExternal: true
    ingressAllowInsecure: false
    ingressTargetPort: 80
    ingressTransport: 'http'
    containers: [
      {
        name: 'malta-catering-app'
        image: '${registryLoginServer}/${containerImageName}:${containerImageTag}'
        resources: {
          cpu: containerCpu
          memory: '0.5Gi'
        }
        env: [
          {
            name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
            secretRef: appInsightsSecretName
          }
          {
            name: 'AZURE_STORAGE_ACCOUNT_NAME'
            value: storageAccountName
          }
          {
            name: 'AZURE_KEYVAULT_URI'
            value: keyVaultUri
          }
        ]
      }
    ]
    registries: [
      {
        server: registryLoginServer
        identity: 'system'
      }
    ]
    secrets: [
      {
        name: appInsightsSecretName
        keyVaultUrl: appInsightsSecretUrl
        identity: 'System'
      }
    ]
    scaleSettings: {
      minReplicas: 0
      maxReplicas: 1
    }
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
    principalId: app.outputs.systemAssignedMIPrincipalId!
    principalType: 'ServicePrincipal'
  }
}

resource storageTableContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, name, 'storage-table-contributor')
  scope: storageAccount
  properties: {
    roleDefinitionId: storageTableContributorRoleDefinitionId
    principalId: app.outputs.systemAssignedMIPrincipalId!
    principalType: 'ServicePrincipal'
  }
}

resource containerRegistryPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, name, 'acr-pull')
  scope: containerRegistry
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: app.outputs.systemAssignedMIPrincipalId!
    principalType: 'ServicePrincipal'
  }
}

output resourceId string = app.outputs.resourceId
output resourceName string = app.outputs.name
output fqdn string = app.outputs.fqdn
output principalId string = app.outputs.systemAssignedMIPrincipalId!
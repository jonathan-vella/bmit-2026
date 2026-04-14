targetScope = 'resourceGroup'

@allowed([
  'all'
  'foundation'
  'security-data-images'
  'compute'
  'cost-monitoring'
])
param phase string = 'all'

param location string = 'swedencentral'
param deploymentEnvironment string = 'dev'
param project string = 'malta-catering'
param owner string
param costcenter string
param application string = 'malta-catering'
param workload string = 'ordering-portal'
param sla string = '99.0'
param backupPolicy string = 'none-demo'
param maintWindow string = 'sun-02-06'

@description('Email used for both technical-contact and tech-contact tags.')
param technicalContact string

param budgetAmount int = 500
param budgetContactEmails array

@description('Budget start date in YYYY-MM-01 format.')
param budgetStartDate string = '2026-05-01'

param containerImageName string = 'malta-catering-app'
param containerImageTag string = 'latest'
param containerAppsWorkloadProfileName string = 'dedicated-d4'
param containerAppsWorkloadProfileType string = 'D4'
param containerAppsWorkloadProfileMinCount int = 1
param containerAppsWorkloadProfileMaxCount int = 1

var uniqueSuffix = take(toLower(uniqueString(resourceGroup().id)), 6)
var shortProject = take(replace(toLower(project), '-', ''), 5)

var governanceTags = {
  Environment: deploymentEnvironment
  Owner: owner
  costcenter: costcenter
  application: application
  workload: workload
  sla: sla
  'backup-policy': backupPolicy
  'maint-window': maintWindow
  'technical-contact': technicalContact
  'tech-contact': technicalContact
}

var baselineTags = {
  ManagedBy: 'Bicep'
  Project: project
}

var resourceTags = union(governanceTags, baselineTags)

var deploySecurityDataImages = contains([
  'all'
  'security-data-images'
  'compute'
  'cost-monitoring'
], phase)

var deployCompute = contains([
  'all'
  'compute'
  'cost-monitoring'
], phase)

var deployCostMonitoring = contains([
  'all'
  'cost-monitoring'
], phase)

var logAnalyticsName = 'log-${project}-${deploymentEnvironment}'
var appInsightsName = 'appi-${project}-${deploymentEnvironment}'
var keyVaultName = take('kv-${shortProject}-${deploymentEnvironment}-${uniqueSuffix}', 24)
var storageAccountName = take('st${shortProject}${deploymentEnvironment}${uniqueSuffix}', 24)
var containerRegistryName = take('acr${shortProject}${deploymentEnvironment}${uniqueSuffix}', 24)
var containerAppsEnvironmentName = 'cae-${project}-${deploymentEnvironment}'
var containerAppName = 'ca-${project}-${deploymentEnvironment}'
var budgetName = 'budget-${project}-${deploymentEnvironment}'

module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'foundation-log-analytics'
  params: {
    name: logAnalyticsName
    location: location
    tags: resourceTags
  }
}

module appInsights 'modules/app-insights.bicep' = {
  name: 'foundation-app-insights'
  params: {
    name: appInsightsName
    location: location
    tags: resourceTags
    workspaceResourceId: logAnalytics.outputs.resourceId
  }
}

module keyVault 'modules/key-vault.bicep' = if (deploySecurityDataImages) {
  name: 'security-key-vault'
  params: {
    name: keyVaultName
    location: location
    tags: resourceTags
    publicNetworkAccess: deploymentEnvironment == 'prod' ? 'Disabled' : 'Enabled'
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
    appInsightsConnectionString: appInsights.outputs.connectionString
  }
}

module storage 'modules/storage.bicep' = if (deploySecurityDataImages) {
  name: 'security-storage'
  params: {
    name: storageAccountName
    location: location
    tags: resourceTags
    publicNetworkAccess: deploymentEnvironment == 'prod' ? 'Disabled' : 'Enabled'
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
  }
}

module containerRegistry 'modules/container-registry.bicep' = if (deploySecurityDataImages) {
  name: 'security-container-registry'
  params: {
    name: containerRegistryName
    location: location
    tags: resourceTags
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
  }
}

module containerAppsEnvironment 'modules/container-apps-env.bicep' = if (deployCompute) {
  name: 'compute-container-apps-environment'
  params: {
    name: containerAppsEnvironmentName
    location: location
    tags: resourceTags
    publicNetworkAccess: deploymentEnvironment == 'prod' ? 'Disabled' : 'Enabled'
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
    workloadProfileName: containerAppsWorkloadProfileName
    workloadProfileType: containerAppsWorkloadProfileType
    workloadProfileMinCount: containerAppsWorkloadProfileMinCount
    workloadProfileMaxCount: containerAppsWorkloadProfileMaxCount
  }
}

module containerApp 'modules/container-app.bicep' = if (deployCompute) {
  name: 'compute-container-app'
  params: {
    name: containerAppName
    location: location
    tags: resourceTags
    environmentResourceId: containerAppsEnvironment!.outputs.resourceId
    workloadProfileName: containerAppsWorkloadProfileName
    keyVaultName: keyVault!.outputs.resourceName
    keyVaultUri: keyVault!.outputs.uri
    storageAccountName: storage!.outputs.resourceName
    containerRegistryName: containerRegistry!.outputs.resourceName
    registryLoginServer: containerRegistry!.outputs.loginServer
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
    containerImageName: containerImageName
    containerImageTag: containerImageTag
  }
}

module budget 'modules/budget.bicep' = if (deployCostMonitoring) {
  name: 'cost-budget'
  params: {
    name: budgetName
    amount: budgetAmount
    contactEmails: budgetContactEmails
    startDate: budgetStartDate
  }
}

output logAnalyticsResourceId string = logAnalytics.outputs.resourceId
output appInsightsConnectionString string = appInsights.outputs.connectionString
output keyVaultUri string = deploySecurityDataImages ? keyVault!.outputs.uri : ''
output storageAccountResourceName string = deploySecurityDataImages ? storage!.outputs.resourceName : ''
output containerRegistryLoginServer string = deploySecurityDataImages ? containerRegistry!.outputs.loginServer : ''
output containerAppsEnvironmentDefaultDomain string = deployCompute ? containerAppsEnvironment!.outputs.defaultDomain : ''
output containerAppFqdn string = deployCompute ? containerApp!.outputs.fqdn : ''
output containerAppPrincipalId string = deployCompute ? containerApp!.outputs.principalId : ''
output budgetResourceId string = deployCostMonitoring ? budget!.outputs.budgetId : ''
targetScope = 'resourceGroup'

@allowed([
  'all'
  'foundation'
  'networking'
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

@description('App Service Plan SKU name.')
param appServicePlanSku string = 'S1'

@description('Enable staging deployment slot on the web app.')
param enableStagingSlot bool = true

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

var deployNetworking = contains([
  'all'
  'networking'
  'security-data-images'
  'compute'
  'cost-monitoring'
], phase)

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
var vnetName = 'vnet-${project}-${deploymentEnvironment}'
var keyVaultName = take('kv-${shortProject}-${deploymentEnvironment}-${uniqueSuffix}', 24)
var storageAccountName = take('st${shortProject}${deploymentEnvironment}${uniqueSuffix}', 24)
var containerRegistryName = take('acr${shortProject}${deploymentEnvironment}${uniqueSuffix}', 24)
var appServicePlanName = 'asp-${project}-${deploymentEnvironment}'
var webAppName = 'app-${project}-${deploymentEnvironment}'
var budgetName = 'budget-${project}-${deploymentEnvironment}'

// ── Phase 1: Foundation ─────────────────────────────────────────────────────

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

// ── Phase 2: Networking ─────────────────────────────────────────────────────

module virtualNetwork 'modules/virtual-network.bicep' = if (deployNetworking) {
  name: 'networking-virtual-network'
  params: {
    name: vnetName
    location: location
    tags: resourceTags
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
  }
}

module privateDnsZones 'modules/private-dns-zones.bicep' = if (deployNetworking) {
  name: 'networking-private-dns-zones'
  params: {
    tags: resourceTags
    virtualNetworkResourceId: virtualNetwork!.outputs.resourceId
  }
}

// ── Phase 3: Security, Data & Images ────────────────────────────────────────

module keyVault 'modules/key-vault.bicep' = if (deploySecurityDataImages) {
  name: 'security-key-vault'
  params: {
    name: keyVaultName
    location: location
    tags: resourceTags
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
    appInsightsConnectionString: appInsights.outputs.connectionString
    privateEndpointSubnetResourceId: virtualNetwork!.outputs.privateEndpointsSubnetResourceId
    privateDnsZoneResourceId: privateDnsZones!.outputs.keyVaultDnsZoneResourceId
  }
}

module storage 'modules/storage.bicep' = if (deploySecurityDataImages) {
  name: 'security-storage'
  params: {
    name: storageAccountName
    location: location
    tags: resourceTags
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
    privateEndpointSubnetResourceId: virtualNetwork!.outputs.privateEndpointsSubnetResourceId
    privateDnsZoneResourceId: privateDnsZones!.outputs.storageTableDnsZoneResourceId
  }
}

module containerRegistry 'modules/container-registry.bicep' = if (deploySecurityDataImages) {
  name: 'security-container-registry'
  params: {
    name: containerRegistryName
    location: location
    tags: resourceTags
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
    privateEndpointSubnetResourceId: virtualNetwork!.outputs.privateEndpointsSubnetResourceId
    privateDnsZoneResourceId: privateDnsZones!.outputs.acrDnsZoneResourceId
  }
}

// ── Phase 4: Compute ────────────────────────────────────────────────────────

module appServicePlan 'modules/app-service-plan.bicep' = if (deployCompute) {
  name: 'compute-app-service-plan'
  params: {
    name: appServicePlanName
    location: location
    tags: resourceTags
    skuName: appServicePlanSku
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
  }
}

module webApp 'modules/web-app.bicep' = if (deployCompute) {
  name: 'compute-web-app'
  params: {
    name: webAppName
    location: location
    tags: resourceTags
    serverFarmResourceId: appServicePlan!.outputs.resourceId
    virtualNetworkSubnetId: virtualNetwork!.outputs.appServiceSubnetResourceId
    keyVaultName: keyVault!.outputs.resourceName
    keyVaultUri: keyVault!.outputs.uri
    storageAccountName: storage!.outputs.resourceName
    containerRegistryName: containerRegistry!.outputs.resourceName
    registryLoginServer: containerRegistry!.outputs.loginServer
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
    containerImageName: containerImageName
    containerImageTag: containerImageTag
    enableStagingSlot: enableStagingSlot
  }
}

// ── Phase 5: Cost Monitoring ────────────────────────────────────────────────

module budget 'modules/budget.bicep' = if (deployCostMonitoring) {
  name: 'cost-budget'
  params: {
    name: budgetName
    amount: budgetAmount
    contactEmails: budgetContactEmails
    startDate: budgetStartDate
  }
}

// ── Outputs ─────────────────────────────────────────────────────────────────

output logAnalyticsResourceId string = logAnalytics.outputs.resourceId
output appInsightsConnectionString string = appInsights.outputs.connectionString
output vnetResourceId string = deployNetworking ? virtualNetwork!.outputs.resourceId : ''
output keyVaultUri string = deploySecurityDataImages ? keyVault!.outputs.uri : ''
output storageAccountResourceName string = deploySecurityDataImages ? storage!.outputs.resourceName : ''
output containerRegistryLoginServer string = deploySecurityDataImages ? containerRegistry!.outputs.loginServer : ''
output webAppDefaultHostname string = deployCompute ? webApp!.outputs.defaultHostname : ''
output webAppPrincipalId string = deployCompute ? webApp!.outputs.principalId : ''
output budgetResourceId string = deployCostMonitoring ? budget!.outputs.budgetId : ''

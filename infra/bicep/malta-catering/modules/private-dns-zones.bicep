@description('Azure region for metadata.')
param location string = 'global'

@description('Resource tags.')
param tags object = {}

@description('Virtual network resource ID for DNS zone links.')
param virtualNetworkResourceId string

var zones = [
  {
    name: 'privatelink.vaultcore.azure.net'
    linkName: 'link-kv'
  }
  {
    name: 'privatelink.table.core.windows.net'
    linkName: 'link-table'
  }
  {
    name: 'privatelink.azurecr.io'
    linkName: 'link-acr'
  }
]

module dnsZones 'br/public:avm/res/network/private-dns-zone:0.7.0' = [
  for zone in zones: {
    name: 'deploy-dns-${replace(zone.name, '.', '-')}'
    params: {
      name: zone.name
      location: location
      tags: tags
      virtualNetworkLinks: [
        {
          virtualNetworkResourceId: virtualNetworkResourceId
          registrationEnabled: false
        }
      ]
      enableTelemetry: false
    }
  }
]

output keyVaultDnsZoneResourceId string = dnsZones[0].outputs.resourceId
output storageTableDnsZoneResourceId string = dnsZones[1].outputs.resourceId
output acrDnsZoneResourceId string = dnsZones[2].outputs.resourceId

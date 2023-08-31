

param grafanaName string
param location string
param solutionTag string
param solutionVersion string
param userObjectId string
param utcValue string = utcNow()

var GrafanaAdminRoleId = '22926164-76b3-42b3-bc55-97df8dab3e41' // Grafana Admin. Need to add to current user.

resource AzureManagedGrafana 'Microsoft.Dashboard/grafana@2022-08-01' = {
  name: grafanaName
  tags: {
    '${solutionTag}': 'storageaccount'
    '${solutionTag}-Version': solutionVersion
  }
  sku: {
    name: 'Standard'
  }
  location: location
}

resource amgAdminRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id,grafanaName,GrafanaAdminRoleId)
  scope: AzureManagedGrafana
  properties: {
    description: '${solutionTag}-GrafanaAdmin-${userObjectId}-${utcValue}'
    principalId: userObjectId
    principalType: 'User'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', GrafanaAdminRoleId)
  }
}

module grafanaReadPermissions '../../../../modules/rbac/resourceGroup/roleassignment.bicep' = {
  name: 'grafanaReadPermissions'
  params: {
    principalId: AzureManagedGrafana.identity.principalId
    resourcename: grafanaName
    roleDefinitionId: ReaderRoleId
    roleShortName: 'Reader'
    solutionTag: solutionTag
    resourceGroupName: lawResourceGroup
  }
}
module grafanaLAWPermissions '../../../../modules/rbac/resourceGroup/roleassignment.bicep' = {
  name: 'grafanaLAWPermissions'
  params: {
    principalId: AzureManagedGrafana.identity.principalId
    resourcename: grafanaName
    roleDefinitionId: LogAnalyticsContribuorRoleId
    roleShortName: 'Log Analytics Contributor'
    solutionTag: solutionTag
    resourceGroupName: lawResourceGroup
  }
}
module grafanaMonitorPermissions '../../../../modules/rbac/resourceGroup/roleassignment.bicep' = {
  name: 'grafanaMonitorPermissions'
  params: {
    principalId: AzureManagedGrafana.identity.principalId
    resourcename: grafanaName
    roleDefinitionId: MonitoringContributorRoleId
    roleShortName: 'Monitor Contributor Role'
    solutionTag: solutionTag
    resourceGroupName: lawResourceGroup
  }
}
output grafanaId string = AzureManagedGrafana.id

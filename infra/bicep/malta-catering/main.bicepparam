using './main.bicep'

param location = 'swedencentral'
param deploymentEnvironment = 'dev'
param project = 'malta-catering'
param owner = 'apex-demo-team'
param costcenter = 'demo-001'
param application = 'malta-catering'
param workload = 'ordering-portal'
param sla = '99.0'
param backupPolicy = 'none-demo'
param maintWindow = 'sun-02-06'
param technicalContact = 'platform@example.com'
param budgetAmount = 500
param budgetContactEmails = [
  'platform@example.com'
]
param budgetStartDate = '2026-05-01'
param containerImageName = 'malta-catering-app'
param containerImageTag = 'latest'
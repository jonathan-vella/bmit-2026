[CmdletBinding()]
param(
    [string]$ResourceGroupName = 'rg-malta-catering-dev',
    [string]$Location = 'swedencentral',
    [string]$Environment = 'dev',
    [ValidateSet('all', 'foundation', 'security-data-images', 'compute', 'cost-monitoring')]
    [string]$Phase = 'all',
    [Parameter(Mandatory)]
    [string]$Owner,
    [Parameter(Mandatory)]
    [string]$CostCenter,
    [string]$Application = 'malta-catering',
    [string]$Workload = 'ordering-portal',
    [string]$Sla = '99.0',
    [string]$BackupPolicy = 'none-demo',
    [string]$MaintWindow = 'sun-02-06',
    [Parameter(Mandatory)]
    [string]$TechnicalContact,
    [Parameter(Mandatory)]
    [string[]]$BudgetContactEmails,
    [int]$BudgetAmount = 500,
    [string]$BudgetStartDate = '2026-05-01',
    [string]$ContainerImageName = 'malta-catering-app',
    [string]$ContainerImageTag = 'latest',
    [switch]$WhatIfDeployment,
    [switch]$SkipApproval
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$scriptRoot = Split-Path -Parent $PSCommandPath
Push-Location $scriptRoot

try {
    if ($BudgetContactEmails.Count -eq 0) {
        throw 'At least one budget alert email address is required.'
    }

    Write-Host 'Running local template validation...' -ForegroundColor Cyan
    & bicep build ./main.bicep --stdout | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw 'bicep build failed.'
    }

    & bicep lint ./main.bicep | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw 'bicep lint failed.'
    }

    $resourceGroupTags = @(
        "environment=$Environment"
        "owner=$Owner"
        "costcenter=$CostCenter"
        "application=$Application"
        "workload=$Workload"
        "sla=$Sla"
        "backup-policy=$BackupPolicy"
        "maint-window=$MaintWindow"
        "technical-contact=$TechnicalContact"
        "tech-contact=$TechnicalContact"
        "Environment=$Environment"
        'ManagedBy=Bicep'
        'Project=malta-catering'
        "Owner=$Owner"
    )

    Write-Host 'Ensuring resource group exists with governance tags...' -ForegroundColor Cyan
    $groupArgs = @('group', 'create', '--name', $ResourceGroupName, '--location', $Location, '--tags') + $resourceGroupTags
    & az @groupArgs | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw 'Resource group creation or tagging failed.'
    }

    $budgetEmailsJson = $BudgetContactEmails | ConvertTo-Json -Compress

    $phases = if ($Phase -eq 'all') {
        @('foundation', 'security-data-images', 'compute', 'cost-monitoring')
    } else {
        @($Phase)
    }

    foreach ($currentPhase in $phases) {
        $deploymentName = "malta-catering-$currentPhase"
        $commonArgs = @(
            '--name', $deploymentName,
            '--resource-group', $ResourceGroupName,
            '--template-file', './main.bicep',
            '--parameters', './main.bicepparam',
            '--parameters', "phase=$currentPhase",
            '--parameters', "location=$Location",
            '--parameters', "deploymentEnvironment=$Environment",
            '--parameters', "owner=$Owner",
            '--parameters', "costcenter=$CostCenter",
            '--parameters', "application=$Application",
            '--parameters', "workload=$Workload",
            '--parameters', "sla=$Sla",
            '--parameters', "backupPolicy=$BackupPolicy",
            '--parameters', "maintWindow=$MaintWindow",
            '--parameters', "technicalContact=$TechnicalContact",
            '--parameters', "budgetAmount=$BudgetAmount",
            '--parameters', "budgetStartDate=$BudgetStartDate",
            '--parameters', "containerImageName=$ContainerImageName",
            '--parameters', "containerImageTag=$ContainerImageTag",
            '--parameters', "budgetContactEmails=$budgetEmailsJson"
        )

        if ($WhatIfDeployment) {
            Write-Host "Running what-if for phase '$currentPhase'..." -ForegroundColor Yellow
            & az deployment group what-if @commonArgs
        } else {
            if (-not $SkipApproval -and $Phase -eq 'all') {
                $approval = Read-Host "Proceed with phase '$currentPhase'? [y/N]"
                if ($approval -notin @('y', 'Y', 'yes', 'YES')) {
                    throw "Deployment halted before phase '$currentPhase'."
                }
            }

            Write-Host "Deploying phase '$currentPhase'..." -ForegroundColor Green
            & az deployment group create @commonArgs
        }

        if ($LASTEXITCODE -ne 0) {
            throw "Azure deployment command failed during phase '$currentPhase'."
        }
    }

    if (-not $WhatIfDeployment) {
        Write-Host 'Fetching deployment outputs...' -ForegroundColor Cyan
        & az deployment group show --resource-group $ResourceGroupName --name ("malta-catering-" + $phases[-1]) --query properties.outputs -o json
    }
}
finally {
    Pop-Location
}
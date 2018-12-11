Param(
    [Parameter(Mandatory = $true)]
    [String] $SubscriptionID,
    [Parameter(Mandatory = $true)]
    [ValidateLength(1, 8)]
    [String] $Name
)

import-module AzureRm.Profile -RequiredVersion 5.6.0
Import-Module AzureRm.Compute

Select-AzureRmSubscription $SubscriptionID | % {
    Write-Host ('Selected AzureRM Subscription: {0}' -f $_.Name) -ForegroundColor Green
}

$ResourceGroup = @{
    Name     = ('rg-{0}-devclient' -f $Name)
    Location = 'West Europe'
}
#region ResourceGroup
$existingObject = Get-AzureRmResourceGroup -Name $ResourceGroup.Name -ErrorAction SilentlyContinue
if (-not $existingObject) {
    Write-Host ('Creating ResourceGroup {0}' -f $ResourceGroup.Name) -ForegroundColor Yellow
    $ResourceGroup.Object = New-AzureRMResourceGroup @ResourceGroup
} else {
    Write-Host ('ResourceGroup {0} is already available' -f $ResourceGroup.Name) -ForegroundColor Green
    $ResourceGroup.Object = $existingObject
}
#endregion

$sw = [system.diagnostics.stopwatch]::startNew()
$Deployment = @{
    Name                    = ('DevClient-' + ((Get-Date).ToUniversalTime()).ToString('ddMMyyyy-HHmmss-fff'))
    ResourceGroupName       = $ResourceGroup.Name
    TemplateFile            = '.\devclient.json'
    TemplateParameterObject = @{
        vmName          = ('{0}-dev-vm' -f $Name)
        vmAdminUserName = 'LocalAdmin'
        vmAdminPassword = 'adm1n@dev'
        vmSize          = 'Standard_D4_v3'
        dnsLabelPrefix  = ('{0}devclient' -f $Name)
    }
    Verbose                 = $true
}
$Deployment.Object = New-AzureRmResourceGroupDeployment @Deployment
$sw | Format-List -Property *

Get-AzureRmRemoteDesktopFile -ResourceGroupName $ResourceGroup.Name -Name $Deployment.Object.Outputs.vmName.Value -Launch -Verbose -Debug

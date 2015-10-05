workflow Get-AzureVMNamesSample
{
    $Cred = Get-AUtomationPSCredential -Name "AzureOrgIdCredential"
    Add-AzureAccount -Credential $Cred -ErrorAction Stop

    $SubscriptionName = Get-AutomationVariable -Name 'AzureSubscriptionName'
    Select-AzureSubscription -SubscriptionName $SubscriptionName

    Get-AzureVM | select InstanceName
}
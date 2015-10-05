<#
    .DESCRIPTION
        An example runbook which prints out the first 10 Azure VMs in your subscription (ordered alphabetically).
        For more information about how this runbook authenticates to your Azure subscription, see our documentation here: http://aka.ms/fxu3mn

    .NOTES
        AUTHOR: Azure Automation Team
        LASTEDIT: Mar 27, 2015
#>
workflow Get-AzureVMTutorial
{
    
    #Get the credential with the above name from the Automation Asset store
    $Cred = Get-AutomationPSCredential -Name 'AzureOrgIdCredential'
    if(!$Cred) {
        Throw "Could not find an Automation Credential Asset named '${CredentialAssetName}'. Make sure you have created one in this Automation Account."
    }

    #Connect to your Azure Account
    $Account = Add-AzureAccount -Credential $Cred
    if(!$Account) {
        Throw "Could not authenticate to Azure using the credential asset '${CredentialAssetName}'. Make sure the user name and password are correct."
    }

    #TODO (optional): pick the right subscription to use. Without this line, the default subscription for your Azure Account will be used.
    $SubName = Get-AutomationVariable -Name 'AzureSubscriptionName'
	Select-AzureSubscription -SubscriptionName $SubName
    
    #Get all the VMs you have in your Azure subscription
    $VMs = Get-AzureVM

    #Print out up to 10 of those VMs
    if(!$VMs) {
        Write-Output "No VMs were found in your subscription."
    } else {
        Write-Output $VMs[0..9]
    }
}
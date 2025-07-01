
<#
 secret.csv file syntax:
        customerId,citrixAPIKey,secretKey
        #########,######-#####-####-####-############,######################

        retrieve users assigned to all machines in a delivery Group.
Example:
UsersAssignedtoaDG.ps1 -secretpath 'c:\temp\secureapi.csv' -deliverygroup 'DeliveryGroupFolder\deliverygorupname'

secretpath his a csv file in this format: customerId,citrixAPIKey,secretKey. If this is not present, user will have to logon explicitly.
deliverygroup is a complete name of a Delivery group to look for (name & folder hierarchy). If not present, the script will look in every delivery Groups.
#>


param(
    [Parameter(Mandatory = $false)] [string]$secretPath, # csv file in this format: customerId,citrixAPIKey,secretKey. If this is not present, user will have to logon explicitely
    [Parameter(Mandatory = $false)] [string]$deliveryGroup # name of a Delivery group to look for. If not present, look in every delivery Groups
)

#-----------------------------
#   Script prerequisites
#-----------------------------
                $ErrorActionPreference = "Stop"
                $Scriptpath = Split-Path $MyInvocation.MyCommand.Path
                # Add Citrix powershell snapins
                try	{
                        $snapin='Citrix*'
		        $snapins = Get-PSSnapin | Where-Object { $_.Name -like $snapin}
		        if ($null -eq $snapins){
                                (Get-PSSnapin -Registered $snapin -ErrorAction stop) | Add-PSSnapin
                                Write-host "Successfully loaded powershell snapin" -ForegroundColor Green 
                        }
                        else{
                              Write-host "Citrix powershell snapin allready there" -ForegroundColor Green                                 
                        }
                }
	        catch{
                        Write-host "An error occured loading powershell snapin" -ForegroundColor Red
		}

#-----------------------------
#   connecting to Citrix DaaS
#-----------------------------
        #initialize secretPath
        if (-NOT $PSBoundParameters.ContainsKey('secretPath')){
            Clear-XDCredentials
            Get-XdAuthentication 
    }
    else{
            #importing secrets: 
            $secret = Import-Csv $secretPath -Delimiter ','
            $customerId = $secret.customerId    
            $citrixAPIKey = $secret.citrixAPIKey
            $secretKey = $secret.secretKEY
        try{
                Clear-XDCredentials |out-null
                # create the connection profile
                set-XDCredentials -CustomerId $customerId -APIKey $citrixAPIKey -SecretKey $secretKEY -ProfileType CloudApi |out-null
                #connect to the profile
		Get-XDAuthentication  |out-null
                Write-host "Successfully connected to Citrix Cloud" -ForegroundColor Green  
        }
        catch {
                Write-host "Error connecting to Citrix Cloud" -ForegroundColor Red 
        }
}
#------------------------------
#   Getting machine informations
#-------------------------------
        if (-NOT $PSBoundParameters.ContainsKey('deliveryGroup')){
        try{
                $machines = Get-BrokerMachine -MaxRecordCount 100000
                $count = $machines.Count
                Write-host "Successfully retrieved $($count) machines from DaaS site" -ForegroundColor Green 
        }
        catch{
                Write-host "Error retrieving machines from DaaS site" -ForegroundColor Green 
        }
    }
else{
        try{
                $machines = Get-BrokerMachine -MaxRecordCount 100000 |Where-Object {$_.DesktopGroupName -eq $deliveryGroup}
                $count = $machines.Count
                Write-host "Successfully retrieved $($count) machines from Delivery Group $($deliveryGroup)" -ForegroundColor Green 
        }
        catch{
                Write-host "Error retrieving machines from Delivery Group $($deliveryGroup)" -ForegroundColor Green 
        }
}

$result = $machines |where-object {$_.Allocationtype -eq 'static'} |select-object machinename,AssociatedUserNames,DesktopGroupName
$result |out-gridview
#-------------------------------
#  disconnecting from Citrix DaaS
#-------------------------------
	
    try{
        $GLOBAL:XDSDKAuth  = 'OnPrem'
        set-XDCredentials -ProfileType OnPrem  |out-null
        #connect to the profile
		Get-XDAuthentication |out-null
        Clear-XDCredentials
    }
    catch{}

# secret.csv file syntax
# customerId,citrixAPIKey,secretKey
#########,######-#####-####-####-############,######################


param(
    [Parameter(Mandatory = $false)] [string]$secretPath # csv file in this format: customerId,citrixAPIKey,secretKey. If this is not present, user will have to logon explicitely
)

#-----------------------------
#   Script prerequisites
#-----------------------------
                $ErrorActionPreference = "Stop"
                $Scriptpath = Split-Path $MyInvocation.MyCommand.Path
                # Create log file
                        $logDir = $Scriptpath+'\Logs'
                        if ((test-path $logDir) -ne "True") {$null = New-Item $Scriptpath\Logs -Type Directory}
                        $logFile  =  Join-Path $logDir ("ConnectDaaS_$($hostname)_$(get-date -format yyyy-MM-dd-hh-mm).log")
                # Import Modules
                        try{
                            Import-Module $Scriptpath\Modules\General.psm1 -Force
                        }
                        catch{
                                Write-host "Error, cannot import Modules or start logging" -ForegroundColor Red 
                        Exit
                        }
                # Add Citrix powershell snapins
                        $result = Add-PowershellSnapin -snapin Citrix*
                        add-LogEntry -logEntry $result -logfile $logFile
                #initialize secretPath
                        if (-NOT $PSBoundParameters.ContainsKey('secretPath')){
                                [string] $secretPath = "$($Scriptpath)\secret.csv"
                        }

#-----------------------------
#   connecting to Citrix DaaS
#-----------------------------
        #initialize secretPath
        if (-NOT $PSBoundParameters.ContainsKey('secretPath')){
      #      Clear-XDCredentials
      #      Get-XdAuthentication 
    }
    else{
            #importing secrets: 
            $secret = Import-Csv $secretPath -Delimiter ','
            $customerId = $secret.customerId    
            $citrixAPIKey = $secret.citrixAPIKey
            $secretKey = $secret.secretKEY
            $result = Connect-DaaS -customerId $customerId -citrixAPIKey $citrixAPIKey -secretKEY $secretKey
            #add the log entry to the log file
            add-LogEntry -logEntry $result -logfile $logFile
            if ($result.level -eq 'Error') {exit}
    }


#-------------------------------
#  disconnecting from Citrix DaaS
#-------------------------------
  #      $result = Disconnect-DaaS
  #      add-LogEntry -logEntry $result -logfile $logFile
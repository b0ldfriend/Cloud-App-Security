function Remove-MCASDiscoveryDataSource
{
    [CmdletBinding()]
    Param
    (
        # Specifies the URL of your CAS tenant, for example 'contoso.portal.cloudappsecurity.com'.
        [Parameter(Mandatory=$false)]
        [ValidateScript({($_.EndsWith('.portal.cloudappsecurity.com') -or $_.EndsWith('.adallom.com'))})]
        [string]$TenantUri,

        # Specifies the CAS credential object containing the 64-character hexadecimal OAuth token used for authentication and authorization to the CAS tenant.
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential,

        # Specifies the name of the data source object to create
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [alias("_id")]
        [string]$Identity,

        [switch]$Quiet
    )

    Try {$TenantUri = Select-MCASTenantUri}
        Catch {Throw $_}

    Try {$Token = Select-MCASToken}
        Catch {Throw $_}

    Try {
        $Response = Invoke-MCASRestMethod2 -Uri "https://$TenantUri/cas/api/v1/discovery/data_sources/$Identity/" -Method Delete -Token $Token
    }
        Catch {
            Throw $_  #Exception handling is in Invoke-MCASRestMethod, so here we just want to throw it back up the call stack, with no additional logic
        }

    If ($Response.StatusCode -eq '200') {
        Write-Verbose "Data source $Identity was removed from MCAS"
        
        if (!$Quiet) {
            $true
        }
    }
    Else {
        Write-Error "Data source $Identity could not be removed from MCAS"
        
        if (!$Quiet) {
            $false
        }
    }
}

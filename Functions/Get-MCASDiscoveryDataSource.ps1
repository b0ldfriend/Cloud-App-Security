function Get-MCASDiscoveryDataSource
{
    [CmdletBinding()]
    Param
    (
        # Specifies the URL of your CAS tenant, for example 'contoso.portal.cloudappsecurity.com'.
        [Parameter(Mandatory=$false)]
        [ValidateScript({(($_.StartsWith('https://') -eq $false) -and ($_.EndsWith('.adallom.com') -or $_.EndsWith('.cloudappsecurity.com')))})]
        [string]$TenantUri,

        # Specifies the CAS credential object containing the 64-character hexadecimal OAuth token used for authentication and authorization to the CAS tenant.
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential
    )
    Try {$TenantUri = Select-MCASTenantUri}
        Catch {Throw $_}

    Try {$Token = Select-MCASToken}
        Catch {Throw $_}
    
    Try {
        $Response = Invoke-MCASRestMethod2 -Uri "https://$TenantUri/cas/api/v1/discovery/data_sources/?skip=0&limit=100&sortField=created&sortDirection=desc" -Method Get -Token $Token
        
    }
    Catch {
        Throw $_  #Exception handling is in Invoke-MCASRestMethod, so here we just want to throw it back up the call stack, with no additional logic
    }

    # Get the response parts and format we need
    $Response = $Response.content

    $Response = $Response | ConvertFrom-Json

    $Response = $Response.data

    $Response
}

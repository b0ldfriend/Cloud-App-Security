function New-MCASDiscoveryDataSource
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
        [Parameter(Mandatory=$true)]
        [string]$Name,
        
        # Specifies the appliance type to use for the format of the block script
        [Parameter(Mandatory=$true)]
        [device_type]$DeviceType,

        # Specifies the type of receiver to create. Possible Values: FTP|Syslog-UDP|Syslog-TCP
        [Parameter(Mandatory=$true)]
        [ValidateSet('FTP','Syslog-UDP','Syslog-TCP')]
        [string]$ReceiverType,

        # Specifies whether to replace the usernames with anonymized identifiers in MCAS (audited de-anonymization of these identifiers is possible)
        [switch]$AnonymizeUsers
    )

    Try {$TenantUri = Select-MCASTenantUri}
        Catch {Throw $_}

    Try {$Token = Select-MCASToken}
        Catch {Throw $_}

    $Body = [ordered]@{'anonymizeUsers'=$AnonymizeUsers;'displayName'=$Name;'logType'=($DeviceType -as [int]);}
    
    switch ($ReceiverType) {
        'FTP' {
            $Body.Add('receiverType','ftp')
            $Body.Add('receiverTypeFull','ftp')
        }
        'Syslog-UDP' {
            $Body.Add('protocol','udp')
            $Body.Add('receiverType','syslog')
            $Body.Add('receiverTypeFull','syslog-udp')
        }
        'Syslog-TCP' {
            $Body.Add('protocol','tcp')
            $Body.Add('receiverType','syslog')
            $Body.Add('receiverTypeFull','syslog-tcp')
        }
    }

    Try {
        $Response = Invoke-MCASRestMethod2 -Uri "https://$TenantUri/cas/api/v1/discovery/data_sources/" -Method Post -Token $Token -Body $Body
    }
        Catch {
            Throw $_  #Exception handling is in Invoke-MCASRestMethod, so here we just want to throw it back up the call stack, with no additional logic
        }
}

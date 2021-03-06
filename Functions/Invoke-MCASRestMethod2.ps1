﻿function Invoke-MCASRestMethod2
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$Uri,

        [Parameter(Mandatory=$true)]
        [ValidateSet('Get','Post','Put','Delete')]
        [string]$Method,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Token,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        $Body,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$ContentType = 'application/json',

        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        $FilterSet
    )

    Do {        
        $CallThrottled = $false
        
        Try {
            If ($Body) {
                $JsonBody = $Body | ConvertTo-Json -Compress -Depth 2

                If ($FilterSet) {
                    $JsonBody = $JsonBody.TrimEnd('}') + ',' + '"filters":{' + ((ConvertTo-MCASJsonFilterString $FilterSet).TrimStart('{')) + '}'
                    }

                Write-Verbose "Invoke-MCASRestMethod: Request body: $JsonBody"
                $Response = Invoke-WebRequest -Uri $Uri -Body $JsonBody -Headers @{Authorization = "Token $Token"} -Method $Method -ContentType $ContentType -UseBasicParsing -ErrorAction Stop
            }
            Else {
                $Response = Invoke-WebRequest -Uri $Uri -Headers @{Authorization = "Token $Token"} -Method $Method -ContentType $ContentType -UseBasicParsing -ErrorAction Stop
            }
        }
        Catch {
            If ($_ -like 'The remote server returned an error: (429) TOO MANY REQUESTS.') {
                #Write-Error '429 - Too many requests. Do not exceed 30 requests/min. Please wait and try again.' -ErrorAction Stop
                Write-Warning '429 - Too many requests. The MCAS API throttling limit has been hit, the call will be retried in 5 second(s)...'
                
                $CallThrottled = $true
                
                Start-Sleep -Seconds 5
            }
            ElseIf ($_ -like 'The remote server returned an error: (403) Forbidden.') {
                Write-Error '403 - Forbidden: Check to ensure the -Credential and -TenantUri parameters are valid and that the specified token is valid.' -ErrorAction Stop
            }
            ElseIf ($_ -match "The remote name could not be resolved: ") {
                Write-Error "The remote name could not be resolved: '$Uri'. Check to ensure the -TenantUri parameter is valid." -ErrorAction Stop
            }
            ElseIf ($_ -like "The remote server returned an error: (404) Not Found.") {
                Write-Error "404 - Not Found: $Identity. Check to ensure the -Identity and -TenantUri parameters are valid." -ErrorAction Stop
            }
            Else {
                Write-Error "Unknown exception when attempting to contact the Cloud App Security REST API: $_" -ErrorAction Stop
            }
        }
    }
    While ($CallThrottled)
    
    Write-Verbose "Invoke-MCASRestMethod: Raw response from MCAS REST API: $Response"
    $Response
}

﻿

# THIS TEST SCRIPT IS STILL IN PROGRESS. IT IS CURRENTLY VERY UGLY. JUST IGNORE IT. THANKS. -Jared


#  Configure interactivity of tests

    $Global:RunInteractiveTests = $false
    $Global:RunTenantSpecificTests = $true
    


$ModuleManifestName = 'Cloud-App-Security.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\$ModuleManifestName"


Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath
        $? | Should Be $true
    }
}

Import-Module $PSScriptRoot\..\Cloud-App-Security.psm1 -Force

$TestsFolder = (Split-Path -Parent -Path $MyInvocation.MyCommand.Path)



. $TestsFolder\Test-Get-MCASCredential.ps1


If ($RunTenantSpecificTests) {
    # Select some users on which to test admin access
    $Global:AdminTestUsers = @('ZrinkaM@jpoeppelnoprev.onmicrosoft.com','ZacharyP@jpoeppelnoprev.onmicrosoft.com')

    . $TestsFolder\Test-Add-MCASAdminAccess.ps1
    . $TestsFolder\Test-Remove-MCASAdminAccess.ps1
}





#Stop-Job -Name MCASTest1 -ErrorAction SilentlyContinue
#Remove-Job -Name MCASTest1 -Force -ErrorAction SilentlyContinue



$CmdletsToTest = @()


# Get-MCASAccount
$ThisCmdlet = @{}
$ThisCmdlet.CmdletName = 'Get-MCASAccount'
#$ThisCmdlet.SupportedParams = @('Identity','Skip','ResultSetSize','SortBy','SortDirection')
$ThisCmdlet.SupportedParams = @('Skip','ResultSetSize','SortBy','SortDirection')
$ThisCmdlet.ResultSetSizeValidRange = @(1,100) 
$ThisCmdlet.ValidSortBy = @('Username','LastSeen') 
$ThisCmdlet.ValidSortDirection = @('Ascending','Descending') 
$CmdletsToTest += $ThisCmdlet


# Get-MCASActivity
$ThisCmdlet = @{}
$ThisCmdlet.CmdletName = 'Get-MCASActivity'
$ThisCmdlet.SupportedParams = @('Identity','Skip','ResultSetSize','SortBy','SortDirection')
$ThisCmdlet.ResultSetSizeValidRange = @(1,100) 
$ThisCmdlet.ValidSortBy = @('Date','Created') 
$ThisCmdlet.ValidSortDirection = @('Ascending','Descending') 
$CmdletsToTest += $ThisCmdlet


# Get-MCASAlert
$ThisCmdlet = @{}
$ThisCmdlet.CmdletName = 'Get-MCASAlert'
$ThisCmdlet.SupportedParams = @('Identity','Skip','ResultSetSize','SortBy','SortDirection')
$ThisCmdlet.ResultSetSizeValidRange = @(1,100) 
$ThisCmdlet.ValidSortBy = @('Date') 
$ThisCmdlet.ValidSortDirection = @('Ascending','Descending') 
$CmdletsToTest += $ThisCmdlet


# Get-MCASFile
$ThisCmdlet = @{}
$ThisCmdlet.CmdletName = 'Get-MCASFile'
$ThisCmdlet.SupportedParams = @('Identity','Skip','ResultSetSize','SortBy','SortDirection')
$ThisCmdlet.ResultSetSizeValidRange = @(1,100) 
$ThisCmdlet.ValidSortBy = @('DateModified') 
$ThisCmdlet.ValidSortDirection = @('Ascending','Descending') 
$CmdletsToTest += $ThisCmdlet


# Get-MCASDiscoveredApp
$ThisCmdlet = @{}
$ThisCmdlet.CmdletName = 'Get-MCASDiscoveredApp'
$ThisCmdlet.SupportedParams = @('Skip','ResultSetSize') # need to add'SortBy','SortDirection'
$ThisCmdlet.ResultSetSizeValidRange = @(1,100) 
$ThisCmdlet.ValidSortBy = @('IpCount','LastUsed','Name','Transactions','Upload','UserCount') 
$ThisCmdlet.ValidSortDirection = @('Ascending','Descending') 
$CmdletsToTest += $ThisCmdlet


# Get-MCASGovernanceAction
$ThisCmdlet = @{}
$ThisCmdlet.CmdletName = 'Get-MCASGovernanceAction'
$ThisCmdlet.SupportedParams = @('Identity','Skip','ResultSetSize','SortBy','SortDirection')
$ThisCmdlet.ResultSetSizeValidRange = @(1,100) 
$ThisCmdlet.ValidSortBy = @('timestamp') 
$ThisCmdlet.ValidSortDirection = @('Ascending','Descending') 
$CmdletsToTest += $ThisCmdlet

<#

# Set-MCASAlert
$ThisCmdlet = @{}
$ThisCmdlet.CmdletName = 'Set-MCASAlert'
$ThisCmdlet.SupportedParams = @('Identity')
$CmdletsToTest += $ThisCmdlet







<#
# Get-MCASAppInfo
$ThisCmdlet = @{}
$ThisCmdlet.CmdletName = 'Get-MCASAppInfo'
$ThisCmdlet.SupportedParams = @('AppId') #need to make a custom test for -AppId for just one value here
$CmdletsToTest += $ThisCmdlet

# Get-MCASReport
$ThisCmdlet = @{}
$ThisCmdlet.CmdletName = 'Get-MCASReport'
$CmdletsToTest += $ThisCmdlet

# Get-MCASStream
$ThisCmdlet = @{}
$ThisCmdlet.CmdletName = 'Get-MCASStream'
$CmdletsToTest += $ThisCmdlet

# Send-MCASDiscoveryLog
$ThisCmdlet = @{}
$ThisCmdlet.CmdletName = 'Send-MCASDiscoveryLog'
$CmdletsToTest += $ThisCmdlet

# Export-MCASBlockScript
$ThisCmdlet = @{}
$ThisCmdlet.CmdletName = 'Export-MCASBlockScript'
$CmdletsToTest += $ThisCmdlet
#>




ForEach ($this in $CmdletsToTest) {
    Describe $this.CmdletName {
        Mock -ModuleName Cloud-App-Security Get-Date { return (New-Object datetime(2000,1,1)) }
    
        Context 'Common Parameter Validation' {

            ## Test null credential (all cmdlets except Get-MCASCredential)
            #If ($this.CmdletName -ne 'Get-MCASCredential' -and $this.ResultSetSizeValidRange) {  
            #    It "Should not accept a null credential" {
            #        {&($this.CmdletName) -Credential $null -ResultSetSize 1} | Should Throw 'Cannot validate argument on parameter'
            #    }                  
            #}
            
            # Test null identity
            If ($this.SupportedParams -contains 'Identity') {      
                It "Should not accept a null identity" {
                    {&($this.CmdletName) -Identity $null} | Should Throw 'Cannot validate argument on parameter'
                }                  
            }
            
            # Test negative value for -Skip
            If ($this.SupportedParams -contains 'Skip') {      
                It "Should not accept a negative value for -Skip" {
                    {&($this.CmdletName) -Skip -1} | Should Throw 'Cannot validate argument on parameter'
                }                  
            }
            
            # Test out of range result set sizes
            If ($this.SupportedParams -contains 'ResultSetSize') {
                $OutOfRangeResultSetSizes = @(($this.ResultSetSizeValidRange[0] - 2),($this.ResultSetSizeValidRange[0] - 1),($this.ResultSetSizeValidRange[1] + 1),($this.ResultSetSizeValidRange[1] + 2))

                ForEach ($i in $OutOfRangeResultSetSizes) {
                    It "Should not accept $i for -ResultSetSize" {
                        {&($this.CmdletName) -ResultSetSize $i} | Should Throw 'Cannot validate argument on parameter'
                    }
                }
            }

            # Test invalid values and combinations of -SortBy and -SortDirection
            If ($this.SupportedParams -contains 'SortBy' -and $this.SupportedParams -contains 'SortDirection') {
                ForEach ($i in $this.ValidSortBy) {
                    It "Should not accept 'invalid' for -SortDirection with -SortBy $i" {
                        {&($this.CmdletName) -SortBy $i -SortDirection 'invalid'} | Should Throw 'Cannot validate argument on parameter'
                        }
                    It "Should not accept -SortBy $i without -SortDirection" {
                        {&($this.CmdletName) -SortBy $i} | Should Throw 'When specifying either the -SortBy or the -SortDirection parameters, you must specify both parameters'
                        }
                    }
                ForEach ($i in $this.ValidSortDirection) {
                    It "Should not accept 'invalid' for -SortBy with -SortDirection $i" {
                        {&($this.CmdletName) -SortDirection $i -SortBy 'invalid'} | Should Throw 'Cannot validate argument on parameter'
                        }
                    It "Should not accept -SortDirection $i without -SortBy" {
                        {&($this.CmdletName) -SortDirection $i} | Should Throw 'When specifying either the -SortBy or the -SortDirection parameters, you must specify both parameters'
                    }
                }
            }
        }

            
        #Context 'Scrypt Analyzer' {
        #    It 'Does not have any issues with the Script Analyzer' {
        #        Invoke-ScriptAnalyzer .\Cloud-App-Security.psm1 | Should be $null
        #   }
        #}
    }
}


<#
Describe 'Get-MCASAccount' {
    Mock -ModuleName Cloud-App-Security Get-Date { return (New-Object datetime(2000,1,1)) }
    
    Context 'Parameter Validation' {

    #region -----------Standard params----------
    $OutOfRangeResultSetSizes = @(-1,0,5001)

    ForEach ($i in $OutOfRangeResultSetSizes) {
        It "Should not accept $i for -ResultSetSize" {
            {Get-MCASAccount -ResultSetSize $i} | Should Throw 'Cannot validate argument on parameter'
            }
        }

   #> 



    #endregion---------------------------------
    
    

    #region -----------Filter params-----------

        #It 'Should not accept a null value for the server' {
            #{Send-SyslogMessage -Server $null -Message 'Test Syslog Message' -Severity 'Alert' -Facility 'auth'} | Should Throw 'The argument is null or empty'
        #}

    #endregion---------------------------------
   

    <#
    Context 'Severity Level Calculations' {
        It 'Calculates the correct priority of 0 if Facility is Kern and Severity is Emergency' {
            $TestCase = "Send-SyslogMessage -Server '127.0.0.1' -Message 'Test Syslog Message' -Severity 'Emergency' -Facility 'kern'"
            $ExpectedResult = '<0>1 {0} TestHostname PowerShell {1} - - Test Syslog Message' -f $ExpectedTimeStamp, $PID
            $TestResult = Test-Message $TestCase
            $TestResult | Should Be $ExpectedResult
        }



    Context 'Function tests' {
        It 'does not return any values' {
            $TestCase = Send-SyslogMessage -Server '127.0.0.1' -Message 'Test Syslog Message' -Severity 'Alert' -Facility 'auth'
            $TestCase | Should be $null
        }
    }

    Context 'Scrypt Analyzer' {
        It 'Does not have any issues with the Script Analyser' {
            Invoke-ScriptAnalyzer .\Cloud-App-Security.psm1 | Should be $null
        }
    }
    

}

#>

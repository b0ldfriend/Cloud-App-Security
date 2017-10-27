function Get-MCASDiscoverySampleLogs
{
    [CmdletBinding()]
    Param
    (
        # Specifies which device type for which a sample log file should be downloaded
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [device_type]$DeviceType
    )
    Begin {
        Add-Type -assembly "system.io.compression.filesystem"
    }
    Process {
        switch ($DeviceType) {
            'BARRACUDA'             {$fileName = 'barracuda-web-app-firewall-w3c_demo_log.log'}
            'BLUECOAT'              {$fileName = 'blue-coat-proxysg-access-log-w3c_demo_log.log'}
            'CHECKPOINT'            {$fileName = 'check-point_demo_log.log'}
            'CISCO_ASA'             {$fileName = 'cisco-asa-firewall_demo_log.log'}
            'CISCO_IRONPORT_PROXY'  {$fileName = 'cisco-ironport-wsa_demo_log.log'}
            'CISCO_FWSM'            {$fileName = 'cisco-fwsm_demo_log.log'}
            'CISCO_SCAN_SAFE'       {$fileName = 'cisco-scansafe_demo_log.log'}
            'CLAVISTER'             {$fileName = 'clavister-ngfw-syslog_demo_log.log'}
            'FORTIGATE'             {$fileName = 'fortinet-fortigate_demo_log.log'}
            'JUNIPER_SRX'           {$fileName = 'juniper-srx_demo_log.log'}
            'JUNIPER_SRX_SD'        {$fileName = 'juniper-srx-sd_demo_log.log'}
            'JUNIPER_SRX_WELF'      {$fileName = 'juniper-srx-welf_demo_log.log'}
            'JUNIPER_SSG'           {$fileName = 'juniper-ssg_demo_log.log'}
            'MACHINE_ZONE_MERAKI'   {$fileName = 'meraki-urls-log_demo_log.log'}
            'MCAFEE_SWG'            {$fileName = 'mcafee-web-gateway_demo_log.log'}
            'MICROSOFT_ISA_W3C'     {$fileName = 'microsoft-forefront-threat-management-gateway-w3c_demo_log.log'}
            'PALO_ALTO'             {$fileName = 'pa-series-firewall_demo_log.log'}
            #'PALO_ALTO_SYSLOG'      {$fileName = ''} # No sample available
            'SONICWALL_SYSLOG'      {$fileName = 'sonicwall_demo_log.log'}
            'SOPHOS_CYBEROAM'       {$fileName = 'sophos-cyberoam-web-filter-and-firewall-log_demo_log.log'}
            'SOPHOS_SG'             {$fileName = 'sophos-sg_demo_log.log'}
            'SQUID'                 {$fileName = 'squid-common_demo_log.log'}
            'SQUID_NATIVE'          {$fileName = 'squid-native_demo_log.log'}
            'WEBSENSE_SIEM_CEF'     {$fileName = 'web-security-solutions-internet-activity-log-cef_demo_log.log'}
            'WEBSENSE_V7_5'         {$fileName = 'web-security-solutions-investigative-detail-report-csv_demo_log.log'}
            'ZSCALER'               {$fileName = 'zscaler-default-csv_demo_log.log'}
            'ZSCALER_QRADAR'        {$fileName = 'zscaler-qradar-leef_demo_log.log'}
        }

        $zipFile = "$fileName.zip"
        $targetFolder = $fileName.Substring(0,($fileName.length-4))

        Try {
            Invoke-WebRequest -Method Get -Uri "https://adaproddiscovery.blob.core.windows.net/logs/$zipFile" -OutFile $zipFile
        }
            Catch {
                Throw "Could not retrieve $zipFile : $_"
            }

        If (Test-Path $targetFolder) {Remove-Item $targetFolder -Recurse -Force}

        Try {
            [io.compression.zipfile]::ExtractToDirectory($zipFile,$targetFolder)
        }
            Catch {
                Throw "Could not extract contents of $zipFile : $_"
            }
       
        Try {
            # Delete the file
            Remove-Item $zipFile -Force
        }
            Catch {
                Throw "Could not delete $zipFile : $_"
            }

            (Get-ChildItem $targetFolder).FullName
    }
    End {}
}

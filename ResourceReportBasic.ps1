#requires -Version 5
#requires -RunAsAdministrator
<#
.SYNOPSIS
   This script will generate a export CVS from the Resource Report API call by Zerto. 
.DESCRIPTION
   This script requires the user to enter the appropriate ZVM IP (RECOVERY SIDE) and user credentials with appropriate Rest API accesss. The script will then query the Zerto Rest API and output a list of 
   virtual machines, respective VPG Name, used storage (MB), source site, target site, and the VPG priority to the PowerShell screen. 
.EXAMPLE
   .\RecourceReportBasic.ps1
.VERSION 
   Applicable versions of Zerto Products script has been tested on.  Unless specified, all scripts in repository will be 5.0u3 and later.  If you have tested the script on multiple
   versions of the Zerto product, specify them here.  If this script is for a specific version or previous version of a Zerto product, note that here and specify that version 
   in the script filename.  If possible, note the changes required for that specific version.  
.LEGAL
   Legal Disclaimer:

----------------------
This script is an example script and is not supported under any Zerto support program or service.
The author and Zerto further disclaim all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.

In no event shall Zerto, its authors or anyone else involved in the creation, production or delivery of the scripts be liable for any damages whatsoever (including, without 
limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or the inability 
to use the sample scripts or documentation, even if the author or Zerto has been advised of the possibility of such damages.  The entire risk arising out of the use or 
performance of the sample scripts and documentation remains with you.
----------------------
#>
#------------------------------------------------------------------------------#
# Declare variables
#------------------------------------------------------------------------------#
#Examples of variables:

##########################################################################################################################
#Any section containing a "GOES HERE" should be replaced and populated with your site information for the script to work.#  
##########################################################################################################################
$ZertoServer = "ZVMIP"
$ZertoPort = "9669"
$ZertoUser = "ZVMUser"
$ZertoPassword = "ZVMPassword"
$ExportCSV = "ExportCSVPath"
################################################
# Creating Arrays for populating Resource Values
################################################
$RPArray = @()

#-----------------------------------------------------------------------------#
# Setting Cert Policy
#-----------------------------------------------------------------------------#
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
#-----------------------------------------------------------------------------#
# Building Zerto API string and invoking API
#-----------------------------------------------------------------------------#
$baseURL = "https://" + $ZertoServer + ":"+$ZertoPort+"/v1/"
#-----------------------------------------------------------------------------#
# Authenticating with Zerto APIs
#-----------------------------------------------------------------------------#
$xZertoSessionURI = $baseURL + "session/add"
$authInfo = ("{0}:{1}" -f $ZertoUser,$ZertoPassword)
$authInfo = [System.Text.Encoding]::UTF8.GetBytes($authInfo)
$authInfo = [System.Convert]::ToBase64String($authInfo)
$headers = @{Authorization=("Basic {0}" -f $authInfo)}
$sessionBody = '{"AuthenticationMethod": "1"}'
$TypeJSON = "application/json"
$TypeXML = "application/xml"

Try
{
$xZertoSessionResponse = Invoke-WebRequest -Uri $xZertoSessionURI -Headers $headers -Method POST -Body $sessionBody -ContentType $TypeJSON
}
Catch
{
Write-host $_.Exception.ToString()
$error[0] | Format-List -force 
}


#-----------------------------------------------------------------------------#
#Extracting x-zerto-session from the response, and adding it to the actual API
#-----------------------------------------------------------------------------#
$xZertoSession = $xZertoSessionResponse.headers.get_item("x-zerto-session")
$zertSessionHeader_json = @{"Accept" = "application/json" 
"x-zerto-session"=$xZertoSession}
#-----------------------------------------------------------------------------#
# Querying API and setting date filters
#-----------------------------------------------------------------------------#
$fromTimeString="2017-09-17"
$toTimeString="2017-09-19"
$startIndex=0
$count=500
$ResourceReportURL="https://" + $ZertoServer + ":"+$ZertoPort+"/ZvmService/ResourcesReport/getSamples?fromTimeString="+$fromTimeString +"&toTimeString="+$toTimeString+"&startIndex="+$startIndex +"&count=" +$count+""
$ResourceRecordsList = Invoke-RestMethod -Uri $ResourceReportURL -TimeoutSec 100 
$ResourceRecordsTable = $ResourceRecordsList.ArrayOfVmResourcesInfo.VmResourcesInfo | select ActiveGuestMemoryInMB,BandwidthInBytes,ConsumedHostMemoryInMB,CpuLimitInMhz,CpuReservedInMhz,CpuUsedInMhz,CrmId,MemoryInMB,MemoryLimitInMB,MemoryReservedInMB,NumberOfVolumes,NumberOfvCpu,RecoveryJournalProvisionedStorageInGB,RecoveryJournalUsedStorageInGB,RecoveryVolumesProvisionedStorageInGB,RecoveryVolumesUsedStorageInGB,ServiceProfile,SourceCluster,SourceHost,SourceOrgVDC,SourceResourcePool,SourceSite,SourceVCDOrg,SourceVolumesProvisionedStorageInGB,SourceVolumesUsedStorageInGB,SourceVraName,StorageProfile,TargetCluster,TargetDatastores,TargetHost,TargetOrgVDC,TargetResourcePool,TargetSite,TargetVCDOrg,TargetVraName,ThroughputInBytes,Timestamp,VmHardwareVersion,VmId,VmName,VpgName,VpgType,Zorg 

Foreach($_ in $ResourceRecordsTable)
{
# Validating if null is needed for data elements
if ($_.ActiveGuestMemoryInMB.nil -eq $true){$_.ActiveGuestMemoryInMB = $null}
if ($_.BandwidthInBytes.nil -eq $true){$_.BandwidthInBytes = $null}
if ($_.ConsumedHostMemoryInMB.nil -eq $true){$_.ConsumedHostMemoryInMB = $null}
if ($_.CpuLimitInMhz.nil -eq $true){$_.CpuLimitInMhz = $null}
if ($_.CpuReservedInMhz.nil -eq $true){$_.CpuReservedInMhz = $null}
if ($_.CpuUsedInMhz.nil -eq $true){$_.CpuUsedInMhz = $null}
if ($_.CrmId.nil -eq $true){$_.CrmId = $null}
if ($_.MemoryInMB.nil -eq $true){$_.MemoryInMB = $null}
if ($_.MemoryLimitInMB.nil -eq $true){$_.MemoryLimitInMB = $null}
if ($_.MemoryReservedInMB.nil -eq $true){$_.MemoryReservedInMB = $null}
if ($_.NumberOfVolumes.nil -eq $true){$_.NumberOfVolumes = $null}
if ($_.NumberOfvCpu.nil -eq $true){$_.NumberOfvCpu = $null}
if ($_.RecoveryJournalProvisionedStorageInGB.nil -eq $true){$_.RecoveryJournalProvisionedStorageInGB = $null}
if ($_.RecoveryJournalUsedStorageInGB.nil -eq $true){$_.RecoveryJournalUsedStorageInGB = $null}
if ($_.RecoveryVolumesProvisionedStorageInGB.nil -eq $true){$_.RecoveryVolumesProvisionedStorageInGB = $null}
if ($_.RecoveryVolumesUsedStorageInGB.nil -eq $true){$_.RecoveryVolumesUsedStorageInGB = $null}
if ($_.ServiceProfile.nil -eq $true){$_.ServiceProfile = $null}
if ($_.SourceCluster.nil -eq $true){$_.SourceCluster = $null}
if ($_.SourceHost.nil -eq $true){$_.SourceHost = $null}
if ($_.SourceOrgVDC.nil -eq $true){$_.SourceOrgVDC = $null}
if ($_.SourceResourcePool.nil -eq $true){$_.SourceResourcePool = $null}
if ($_.SourceSite.nil -eq $true){$_.SourceSite = $null}
if ($_.SourceVCDOrg.nil -eq $true){$_.SourceVCDOrg = $null}
if ($_.SourceVolumesProvisionedStorageInGB.nil -eq $true){$_.SourceVolumesProvisionedStorageInGB = $null}
if ($_.SourceVolumesUsedStorageInGB.nil -eq $true){$_.SourceVolumesUsedStorageInGB = $null}
if ($_.SourceVraName.nil -eq $true){$_.SourceVraName = $null}
if ($_.StorageProfile.nil -eq $true){$_.StorageProfile = $null}
if ($_.TargetCluster.nil -eq $true){$_.TargetCluster = $null}
if ($_.TargetDatastores.nil -eq $true){$_.TargetDatastores = $null}
if ($_.TargetHost.nil -eq $true){$_.TargetHost = $null}
if ($_.TargetOrgVDC.nil -eq $true){$_.TargetOrgVDC = $null}
if ($_.TargetResourcePool.nil -eq $true){$_.TargetResourcePool = $null}
if ($_.TargetSite.nil -eq $true){$_.TargetSite = $null}
if ($_.TargetVCDOrg.nil -eq $true){$_.TargetVCDOrg = $null}
if ($_.TargetVraName.nil -eq $true){$_.TargetVraName = $null}
if ($_.ThroughputInBytes.nil -eq $true){$_.ThroughputInBytes = $null}
if ($_.Timestamp.nil -eq $true){$_.Timestamp = $null}else{$_.Timestamp = Date($_.Timestamp)}
if ($_.VmHardwareVersion.nil -eq $true){$_.VmHardwareVersion = $null}
if ($_.VmId.nil -eq $true){$_.VmId = $null}else{
    $_ | Add-Member -MemberType NoteProperty -Name "InternalVMName" -Value $_.VmId.InternalVmName
    $_ | Add-Member -MemberType NoteProperty -Name "ServerIdentifier" -Value $_.VmId.ServerIdentifier.ServerGuid
    $_.VmId = $null
}
if ($_.VmName.nil -eq $true){$_.VmName = $null}
if ($_.VpgName.nil -eq $true){$_.VpgName = $null}
if ($_.VpgType.nil -eq $true){$_.VpgType = $null}
if ($_.Zorg.nil -eq $true){$_.Zorg.nil = $null}

$RPArray += $_

}



#-----------------------------------------------------------------------------#
# Exporting table to CSV
#-----------------------------------------------------------------------------#
$RPArray | Export-Csv $ExportCSV -NoTypeInformation -force -Encoding ASCII

#-----------------------------------------------------------------------------#
# Selecting VPG name in table
#-----------------------------------------------------------------------------#
# If selection of a specific VPG is required, uncomment the lines below
#$VMListTableFiltered = $VMListTable | Where-Object VpgName -EQ "Enter VPG Name" | format-table -AutoSize
#Write-Output $VMListTableFiltered
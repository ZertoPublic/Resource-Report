# Legal Disclaimer
This script is an example script and is not supported under any Zerto support program or service. The author and Zerto further disclaim all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.

In no event shall Zerto, its authors or anyone else involved in the creation, production or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or the inability to use the sample scripts or documentation, even if the author or Zerto has been advised of the possibility of such damages. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.

# Resource Report 
This script requires the user to enter the appropriate ZVM IP (RECOVERY SIDE) and user credentials with appropriate Rest API accesss. The script will then query the Zerto Rest API and output a list of virtual machines, respective VPG Name, used storage (MB), source site, target site, and the VPG priority to the PowerShell screen. 

The script can be run in a VMware or Hyper-V Zerto environment. 

# Prerequisities 
Environment Requirements:
  - PowerShell 5.0+
  - ZVR 5.0u3+ 
  - Run as Administrator
  
Script Requirements:
  - ZVM IP 
  - ZVM User / password
  - Export CSV Path 
# Running Script
Once the necessary requirements have been completed select an appropriate host to run the script from. To run the script type the following:

.\ResourceReportBasic.PS1

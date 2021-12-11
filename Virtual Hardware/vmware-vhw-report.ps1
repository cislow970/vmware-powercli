#---------------------------------------------------------------------------------------------------------
# Description:   	Retrieve virtual hardware informations
# Date:   			Nov 03, 2020
# Author: 			Danilo Cilento (danilo.cilento@gmail.com)
# References:		https://kb.vmware.com/s/article/2143832 (ESXi Build numbers and versions)
#					https://kb.vmware.com/s/article/1003746 (Virtual Hardware Version)
#
#					Product					Major release	Build Number	Release Date	vHW Version		
#					ESXi 7.0 U1 (7.0.1)		7.0.0			16850804		10/06/2020      vmx-18			
#					ESXi 7.0 (7.0.0)		7.0.0			15843807		04/02/2020      vmx-17			
#					ESXi 6.7 U2				6.7.0			13006603		04/11/2019      vmx-15			
#					ESXi 6.7				6.7.0			8169922			04/17/2018      vmx-14			
#					ESXi 6.5				6.5.0			4564106			11/15/2016      vmx-13			
#					ESXi 6.0				6.0.0			2494585			03/12/2015      vmx-11			
#					ESXi 5.5				5.5.0			1331820			09/22/2013      vmx-10			
#					ESXi 5.1				5.1.0			799733			09/10/2012      vmx-09			
#					ESXi 5.0				5.0.0			469512			08/24/2011      vmx-08			
#---------------------------------------------------------------------------------------------------------

param(
	[Parameter(
		Mandatory = $true,
		HelpMessage = 'Enter the report name with complete file path (CSV format)!'
	)] [String]$Save
)

New-VIProperty -Name ToolsVersion -ObjectType VirtualMachine -ValueFromExtensionProperty 'Config.tools.ToolsVersion' -Force | Out-Null
New-VIProperty -Name ToolsVersionStatus -ObjectType VirtualMachine -ValueFromExtensionProperty 'Guest.ToolsVersionStatus' -Force | Out-Null

$vHWmatrix = @(
	@{
		product = 'ESXi 7.0 U1 (7.0.1)'
		major = '7.0.0'
		build = 16850804
		date = '10/06/2020'
		vhw = 'vmx-18'
	},
	@{
		product = 'ESXi 7.0 (7.0.0)'
		major = '7.0.0'
		build = 15843807
		date = '04/02/2020'
		vhw = 'vmx-17'
	},
	@{
		product = 'ESXi 6.7 U2'
		major = '6.7.0'
		build = 13006603
		date = '04/11/2019'
		vhw = 'vmx-15'
	},
	@{
		product = 'ESXi 6.7'
		major = '6.7.0'
		build = 8169922
		date = '04/17/2018'
		vhw = 'vmx-14'
	},
	@{
		product = 'ESXi 6.5'
		major = '6.5.0'
		build = 4564106
		date = '11/15/2016'
		vhw = 'vmx-13'
	},
	@{
		product = 'ESXi 6.0'
		major = '6.0.0'
		build = 2494585
		date = '03/12/2015'
		vhw = 'vmx-11'
	},
	@{
		product = 'ESXi 5.5'
		major = '5.5.0'
		build = 1331820
		date = '09/22/2013'
		vhw = 'vmx-10'
	},
	@{
		product = 'ESXi 5.1'
		major = '5.1.0'
		build = 799733
		date = '09/10/2012'
		vhw = 'vmx-09'
	},
	@{
		product = 'ESXi 5.0'
		major = '5.0.0'
		build = 469512
		date = '08/24/2011'
		vhw = 'vmx-08'
	}
)

$vHWreport = @()

$ESX = Get-VMHost

$ESX | %{
	$esxName = $_.Name
	$clusterName = ($_ | Get-Cluster).Name

	$esxMoreInfo = $_ | Get-View
	$esxType = $esxMoreInfo.Config.Product.Name
	$esxVersion = $esxMoreInfo.Config.Product.Version
	$esxBuild = $esxMoreInfo.Config.Product.Build
	
	foreach ($elem in $vHWmatrix) {
		if ($esxVersion -eq $elem.major) {
			if ([Int]$esxBuild -ge [Int]$elem.build) {
				$vHWmax = $elem.vhw
				break
			}
		}
	}
	
	$VMs = $_ | Get-VM
	$VMs | %{
		$row = "" | Select "VM Name",
						   "Guest OS",
						   "Power State",
						   "Current vHW",
						   "Maximum vHW",
						   "Tools Version",
						   "Tools Version Status",
						   "Hypervisor Name",
						   "Hypervisor Type",
						   "Hypervisor Version",
						   "Hypervisor Build",
						   "Cluster Name"
		$row."VM Name" = $_.Name
		$row."Guest OS" = $_.ExtensionData.Config.GuestFullName
		$row."Power State" = $_.PowerState
		$row."Current vHW" = $_.HardwareVersion
		$row."Maximum vHW" = $vHWmax
		$row."Tools Version" = $_.ToolsVersion
		$row."Tools Version Status" = $_.ToolsVersionStatus
		$row."Hypervisor Name" = $esxName
		$row."Hypervisor Type" = $esxType
		$row."Hypervisor Version" = $esxVersion
		$row."Hypervisor Build" = $esxBuild
		$row."Cluster Name" = $clusterName

		$vHWreport += $row
	}
}

$vHWreport | Export-Csv -Delimiter ";" -NoTypeInformation $Save

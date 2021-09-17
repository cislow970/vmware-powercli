#---------------------------------------------------------------------------
# Author: <danilo.cilento@gmail.com>
# Desc:   Tag query
# Date:   Sep 07, 2021
#---------------------------------------------------------------------------

$global:Tagging = "C:\Tagging"

function RefreshCacheVM() {
	param (
		[Parameter(Mandatory = $true)] [String]$VIServer
	)

    # Get credentials
    $Creds = $host.ui.PromptForCredential("Login to vCenter", "Please enter your user name and password.", "", "")
    
    Connect-VIServer -Server $VIServer -Credential $Creds | Out-Null
    
    # Create an array of VM IDs
    $allVMs = Get-VM
    $VMIDs = @()

    for ($i = 0; $i -lt $allVMs.Count; $i++) {
        $VMName = $allVMs[$i].Name
        $VMInfo = $allVMs[$i].ExtensionData.MoRef

        $VMSpec = New-Object PSObject -Property @{
            id = $VMInfo.value
            type = $VMInfo.type
        }

        $VMIDs += New-Object PSObject -Property @{
            name = $VMName
            object = $VMSpec
        }
    }
    
    if (-not (Test-Path -Path "$global:Tagging\TagCache")) {
        New-Item -ItemType Directory -Path "$global:Tagging\TagCache"
    }

    # Save VM IDs to JSON file
    $VMIDs | ConvertTo-JSON | Out-File "$global:Tagging\TagCache\${VIServer}_vm.json"

    Disconnect-VIServer -Server $VIServer -Confirm:$false
}

function RefreshCacheCluster() {
    param (
        [Parameter(Mandatory = $true)] [String]$VIServer
    )
    
    # Get credentials
    $Creds = $host.ui.PromptForCredential("Login to vCenter", "Please enter your user name and password.", "", "")
    
    Connect-VIServer -Server $VIServer -Credential $Creds | Out-Null
    
    # Create an array of Cluster IDs
    $allClusters = Get-Cluster
    $ClusterIDs = @()

    for ($i = 0; $i -lt $allClusters.Count; $i++) {
        $ClusterName = $allClusters[$i].Name
        $ClusterInfo = $allClusters[$i].ExtensionData.MoRef

        $ClusterSpec = New-Object PSObject -Property @{
            id = $ClusterInfo.value
            type = $ClusterInfo.type
        }

        $ClusterIDs += New-Object PSObject -Property @{
            name = $ClusterName
            object = $ClusterSpec
        }
    }
    
    if (-not (Test-Path -Path "$global:Tagging\TagCache")) {
        New-Item -ItemType Directory -Path "$global:Tagging\TagCache"
    }

    # Save Cluster IDs to JSON file
    $ClusterIDs | ConvertTo-JSON | Out-File "$global:Tagging\TagCache\${VIServer}_cluster.json"

    Disconnect-VIServer -Server $VIServer -Confirm:$false
}

function RefreshCacheESX() {
    param (
        [Parameter(Mandatory = $true)] [String]$VIServer
    )
    
    # Get credentials
    $Creds = $host.ui.PromptForCredential("Login to vCenter", "Please enter your user name and password.", "", "")
    
    Connect-VIServer -Server $VIServer -Credential $Creds | Out-Null
    
    # Create an array of ESX IDs
    $allESX = Get-VMHost
    $ESXIDs = @()

    for ($i = 0; $i -lt $allESX.Count; $i++) {
        $ESXName = $allESX[$i].Name
        $ESXInfo = $allESX[$i].ExtensionData.MoRef

        $ESXSpec = New-Object PSObject -Property @{
            id = $ESXInfo.value
            type = $ESXInfo.type
        }

        $ESXIDs += New-Object PSObject -Property @{
            name = $ESXName
            object = $ESXSpec
        }
    }
    
    if (-not (Test-Path -Path "$global:Tagging\TagCache")) {
        New-Item -ItemType Directory -Path "$global:Tagging\TagCache"
    }

    # Save ESX IDs to JSON file
    $ESXIDs | ConvertTo-JSON | Out-File "$global:Tagging\TagCache\${VIServer}_esx.json"

    Disconnect-VIServer -Server $VIServer -Confirm:$false
}

function RefreshCacheDatastore() {
    param (
        [Parameter(Mandatory = $true)] [String]$VIServer
    )
    
    # Get credentials
    $Creds = $host.ui.PromptForCredential("Login to vCenter", "Please enter your user name and password.", "", "")
    
    Connect-VIServer -Server $VIServer -Credential $Creds | Out-Null
    
    # Create an array of Datastore IDs
    $allDatastores = Get-Datastore | where { ($_.Extensiondata.Summary.MultipleHostAccess) -and ($_.Type -eq "VMFS") }
    $DatastoreIDs = @()

    for ($i = 0; $i -lt $allDatastores.Count; $i++) {
        $DSName = $allDatastores[$i].Name
        $DSInfo = $allDatastores[$i].ExtensionData.MoRef

        $DSSpec = New-Object PSObject -Property @{
            id = $DSInfo.value
            type = $DSInfo.type
        }

        $DatastoreIDs += New-Object PSObject -Property @{
            name = $DSName
            object = $DSSpec
        }
    }
    
    if (-not (Test-Path -Path "$global:Tagging\TagCache")) {
        New-Item -ItemType Directory -Path "$global:Tagging\TagCache"
    }

    # Save Datastore IDs to JSON file
    $DatastoreIDs | ConvertTo-JSON | Out-File "$global:Tagging\TagCache\${VIServer}_datastore.json"

    Disconnect-VIServer -Server $VIServer -Confirm:$false
}

function RefreshCacheTag() {
	param (
		[Parameter(Mandatory = $true)] [String]$VIServer
	)
    
    # Get credentials
    $Creds = $host.ui.PromptForCredential("Login to vCenter", "Please enter your user name and password.", "", "")
    
    Connect-CisServer -Server $VIServer -Credential $Creds | Out-Null
    
    $allTagMethodSVC = Get-CisService com.vmware.cis.tagging.tag -Server $VIServer
    $allTags = @()
    $allTags = $allTagMethodSVC.list()
    $TagIDs = @()
    foreach ($tag in $allTags) {
        $TagIDs += New-Object PSObject -Property @{
            id = $tag.Value
            name = ($allTagMethodSVC.get($tag.Value)).Name
        }
    }

    if (-not (Test-Path -Path "$global:Tagging\TagCache")) {
        New-Item -ItemType Directory -Path "$global:Tagging\TagCache"
    }

    # Save tag IDs to JSON file
    $TagIDs | ConvertTo-JSON | Out-File "$global:Tagging\TagCache\${VIServer}_tag.json"

    Disconnect-CisServer -Server $VIServer -Confirm:$false
}

function RefreshCacheCategory() {
	param (
		[Parameter(Mandatory = $true)] [String]$VIServer
	)
    
    # Get credentials
    $Creds = $host.ui.PromptForCredential("Login to vCenter", "Please enter your user name and password.", "", "")
    
    Connect-CisServer -Server $VIServer -Credential $Creds | Out-Null
    
    $allCategoryMethodSVC = Get-CisService com.vmware.cis.tagging.category -Server $VIServer
    $allCategories = @()
    $allCategories = $allCategoryMethodSVC.list()
    $CategoryIDs = @()
    foreach ($category in $allCategories) {
        $CategoryIDs += New-Object PSObject -Property @{
            id = $category.Value
            name = ($allCategoryMethodSVC.get($category.Value)).Name
        }
    }

    if (-not (Test-Path -Path "$global:Tagging\TagCache")) {
        New-Item -ItemType Directory -Path "$global:Tagging\TagCache"
    }

    # Save category IDs to JSON file
    $CategoryIDs | ConvertTo-JSON | Out-File "$global:Tagging\TagCache\${VIServer}_category.json"

    Disconnect-CisServer -Server $VIServer -Confirm:$false
}

function RefreshCacheTagxCategory() {
	param (
		[Parameter(Mandatory = $true)] [String]$VIServer
	)
    
    # Get credentials
    $Creds = $host.ui.PromptForCredential("Login to vCenter", "Please enter your user name and password.", "", "")
    
    Connect-CisServer -Server $VIServer -Credential $Creds | Out-Null
    
    $allCategoryMethodSVC = Get-CisService com.vmware.cis.tagging.category -Server $VIServer
    $allTagMethodSVC = Get-CisService com.vmware.cis.tagging.tag -Server $VIServer
    $allCategories = @()
    $allCategories = $allCategoryMethodSVC.list()
    $TagIDsxCategory = @()
    foreach ($category in $allCategories) {
        $TagIDsxCategory += New-Object PSObject -Property @{
            id = $category.Value
            tag = $allTagMethodSVC.list_tags_for_category($category)
        }
    }

    if (-not (Test-Path -Path "$global:Tagging\TagCache")) {
        New-Item -ItemType Directory -Path "$global:Tagging\TagCache"
    }

    # Save tag IDs per category to JSON file
    $TagIDsxCategory | ConvertTo-JSON | Out-File "$global:Tagging\TagCache\${VIServer}_tagxcategory.json"

    Disconnect-CisServer -Server $VIServer -Confirm:$false
}

function LoadCacheVM() {
	param (
		[Parameter(Mandatory = $true)] [String]$VIServer
	)

    # Load VM IDs from JSON file
    if (Test-Path -Path "$global:Tagging\TagCache\${VIServer}_vm.json") {
        $allVMId = Get-Content "$global:Tagging\TagCache\${VIServer}_vm.json" | Out-String | ConvertFrom-Json
        return $allVMId
    } else {
        Write-Host "VM Cache for vCenter ${VIServer} does not exists" -ForegroundColor Red
        break
    }
}

function LoadCacheCluster() {
    param (
        [Parameter(Mandatory = $true)] [String]$VIServer
    )

    # Load Cluster IDs from JSON file
    if (Test-Path -Path "$global:Tagging\TagCache\${VIServer}_cluster.json") {
        $allClusterId = Get-Content "$global:Tagging\TagCache\${VIServer}_cluster.json" | Out-String | ConvertFrom-Json
        return $allClusterId
    } else {
        Write-Host "Cluster Cache for vCenter ${VIServer} does not exists" -ForegroundColor Red
        break
    }
}

function LoadCacheESX() {
    param (
        [Parameter(Mandatory = $true)] [String]$VIServer
    )

    # Load ESX IDs from JSON file
    if (Test-Path -Path "$global:Tagging\TagCache\${VIServer}_esx.json") {
        $allESXId = Get-Content "$global:Tagging\TagCache\${VIServer}_esx.json" | Out-String | ConvertFrom-Json
        return $allESXId
    } else {
        Write-Host "ESX Cache for vCenter ${VIServer} does not exists" -ForegroundColor Red
        break
    }
}

function LoadCacheDatastore() {
    param (
        [Parameter(Mandatory = $true)] [String]$VIServer
    )

    # Load Datastore IDs from JSON file
    if (Test-Path -Path "$global:Tagging\TagCache\${VIServer}_datastore.json") {
        $allDSId = Get-Content "$global:Tagging\TagCache\${VIServer}_datastore.json" | Out-String | ConvertFrom-Json
        return $allDSId
    } else {
        Write-Host "Datastore Cache for vCenter ${VIServer} does not exists" -ForegroundColor Red
        break
    }
}

function LoadCacheTag() {
	param (
		[Parameter(Mandatory = $true)] [String]$VIServer
	)

    # Load tag IDs from JSON file
    if (Test-Path -Path "$global:Tagging\TagCache\${VIserver}_tag.json") {
        $allTagId = Get-Content "$global:Tagging\TagCache\${VIserver}_tag.json" | Out-String | ConvertFrom-Json
        return $allTagId
    } else {
        Write-Host "Tag Cache for vCenter ${VIServer} does not exists" -ForegroundColor Red
        break
    }
}

function LoadCacheCategory() {
	param (
		[Parameter(Mandatory = $true)] [String]$VIServer
	)

    # Load category IDs from JSON file
    if (Test-Path -Path "$global:Tagging\TagCache\${VIserver}_category.json") {
        $allCategoryId = Get-Content "$global:Tagging\TagCache\${VIserver}_category.json" | Out-String | ConvertFrom-Json
        return $allCategoryId
    } else {
        Write-Host "Category Cache for vCenter ${VIServer} does not exists" -ForegroundColor Red
        break
    }
}

function LoadCacheTagxCategory() {
	param (
		[Parameter(Mandatory = $true)] [String]$VIServer
	)

    # Load tag IDs per category from JSON file
    if (Test-Path -Path "$global:Tagging\TagCache\${VIserver}_tagxcategory.json") {
        $allTagIdxCategory = Get-Content "$global:Tagging\TagCache\${VIserver}_tagxcategory.json" | Out-String | ConvertFrom-Json
        return $allTagIdxCategory
    } else {
        Write-Host "TagxCategory Cache for vCenter ${VIServer} does not exists" -ForegroundColor Red
        break
    }
}

function ListTagsAssociatedToVM() {
    param (
        [Parameter(Mandatory = $true)] [String]$VIServer,
        [Parameter(Mandatory = $true)] [String]$VMName,
        [Switch]$ExportCSV
    )
    
    # Get credentials
    $Creds = $host.ui.PromptForCredential("Login to vCenter", "Please enter your user name and password.", "", "")
    
    Connect-CisServer -Server $VIServer -Credential $Creds | Out-Null
    
    $allCategoryMethodSVC = Get-CisService com.vmware.cis.tagging.category -Server $VIServer
    $allTagMethodSVC = Get-CisService com.vmware.cis.tagging.tag -Server $VIServer
    $allTagAssociationMethodSVC = Get-CisService com.vmware.cis.tagging.tag_association -Server $VIServer

    $VMIDs = LoadCacheVM $VIServer

    $useThisVMID = $null
    foreach ($vm in $VMIDs) {
        if ($vm.name -eq $VMName) {
            $useThisVMID = $vm.object
        }
    }

    if ($useThisVMID) {
        $tagList = $allTagAssociationMethodSVC.list_attached_tags($useThisVMID)
        if ($tagList) {
            $result = @()
            $allTags = LoadCacheTag $VIServer
            $allCategories = LoadCacheCategory $VIServer
            $allTagsxCategory = LoadCacheTagxCategory $VIServer
            foreach ($id in $tagList) {
                foreach ($tag in $allTags) {
                    if ($tag.id -eq $id) {
                        foreach ($elem in $allTagsxCategory) {
                            foreach ($item in $elem.tag) {
                                if ($tag.id -eq $item) {
                                    foreach ($category in $allCategories) {
                                        if ($category.id -eq $elem.id) {
                                            $val = [PSCustomObject]@{'Tag'=$tag.name;'Category'=$category.name}
                                            $result += $val
                                        }
                                    }
                                }                                
                            }                            
                        }
                    }                
                }
            }

            $result | Out-GridView -Title "VM ${VMName} Tags"
        } else {
            Write-Host "VM ${VMName} is not associated to any Tag" -ForegroundColor Red
            Disconnect-CisServer -Server $VIServer -Confirm:$false
            break
        }
    } else {
        Write-Host "ID of VM [${VMName}] does not exists" -ForegroundColor Red
        Disconnect-CisServer -Server $VIServer -Confirm:$false
        break
    }

    if ($ExportCSV) {
        if (-not (Test-Path -Path "$global:Tagging\TagQuery")) {
            New-Item -ItemType Directory -Path "$global:Tagging\TagQuery"
        }
    
        $result | Export-Csv -NoTypeInformation -Delimiter ";" -Path "$global:Tagging\TagQuery\${VMName}_Tags.csv"
    }

    Disconnect-CisServer -Server $VIServer -Confirm:$false
}

function ListVMsAssociatedToTag() {
    param (
        [Parameter(Mandatory = $true)] [String]$VIServer,
        [Parameter(Mandatory = $true)] [String]$TagName,
        [Switch]$ExportCSV
    )
    
    # Get credentials
    $Creds = $host.ui.PromptForCredential("Login to vCenter", "Please enter your user name and password.", "", "")
    
    Connect-CisServer -Server $VIServer -Credential $Creds | Out-Null

    $allTagMethodSVC = Get-CisService com.vmware.cis.tagging.tag -Server $VIServer
    $allTagAssociationMethodSVC = Get-CisService com.vmware.cis.tagging.tag_association -Server $VIServer

    # Retrieving a tag ID from its name
    $allTags = LoadCacheTag $VIServer
    $allVMs = LoadCacheVM $VIServer

    foreach ($tag in $allTags) {
        if ($tag.name -eq $TagName) {
            $tagId = $tag.id
        }            
    }

    if ($tagId) {
        # Get VM associated to tag ID
        $ObjsList = $allTagAssociationMethodSVC.list_attached_objects($tagId)

        if ($ObjsList) {
            $result = @()
            foreach ($obj in $ObjsList) {
                if ($obj.type -eq "VirtualMachine") {
                    foreach ($elem in $allVMs) {
                        if ($elem.object.id -eq $obj.id) {
                            $val = [PSCustomObject]@{'VM'=$elem.name;'Tag'=$TagName}
                            $result += $val
                        }
                    }
                }
            }

            $result | Out-GridView -Title "VMs associated to Tag [${TagName}]"
        } else {
            Write-Host "Tag ${TagName} is not associated to any VM" -ForegroundColor Red
            Disconnect-CisServer -Server $VIServer -Confirm:$false
            break
        }
    } else {
        Write-Host "ID of Tag [${TagName}] does not exists" -ForegroundColor Red
        Disconnect-CisServer -Server $VIServer -Confirm:$false
        break
    }
	
    if ($ExportCSV) {
        if (-not (Test-Path -Path "$global:Tagging\TagQuery")) {
            New-Item -ItemType Directory -Path "$global:Tagging\TagQuery"
        }
    
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $result | Export-Csv -NoTypeInformation -Delimiter ";" -Path "$global:Tagging\TagQuery\VMsAssociatedToSingleTag_${timestamp}.csv"
    }

    Disconnect-CisServer -Server $VIServer -Confirm:$false
}

function ListTagsAssociatedToVMs() {
    param (
        [Parameter(Mandatory = $true)] [String]$VIServer,
        [Parameter(Mandatory = $true)] [String]$VMList,
        [Switch]$ExportCSV
    )
    
    # Get credentials
    $Creds = $host.ui.PromptForCredential("Login to vCenter", "Please enter your user name and password.", "", "")
    
    Connect-CisServer -Server $VIServer -Credential $Creds | Out-Null

    $allTagAssociationMethodSVC = Get-CisService com.vmware.cis.tagging.tag_association -Server $VIServer

    # Warning: Get associations with maximum 2000 VMs for each request 
    if (Test-Path -Path "$VMList") {
        $FilterByVMs = Get-Content $VMList
        if ($FilterByVMs.lenght -gt 2000) {
            Write-Host "VMs filter list is too large" -ForegroundColor Red
            break
        }
    } else {
        Write-Host "VMs filter list does not exists" -ForegroundColor Red
        break
    }
    
    $allVMs = LoadCacheVM $VIServer
    $allTags = LoadCacheTag $VIServer
    $allCategories = LoadCacheCategory $VIServer
    $allTagsxCategory = LoadCacheTagxCategory $VIServer

    # Assume a list of VM IDs
    $useTheseVMIDs = @()
    foreach ($elem in $FilterByVMs) {
        foreach ($vm in $allVMs) {
            if ($vm.name -eq $elem) {
                $useTheseVMIDs += $vm.object
            }
        }
    }

    $TagAssocList = @()
    $TagAssocList = $allTagAssociationMethodSVC.list_attached_tags_on_objects($useTheseVMIDs)
    
    if ($TagAssocList.Count -gt 0) {
        $result = @()
        foreach ($elem in $TagAssocList) {
            foreach ($vm in $allVMs) {
                if ($vm.object.id -eq $elem.object_id.id) {
                    $VMLabel = $vm.name
                }
            }

            $TagCategoryLabels = @()
            foreach ($id in $elem.tag_ids) {
                foreach ($tag in $allTags) {
                    if ($tag.id -eq $id) {
                        $TagLabel = $tag.name

                        foreach ($item in $allTagsxCategory) {
                            foreach ($tagId in $item.tag) {
                                if ($tagId -eq $id) {
                                    foreach ($category in $allCategories) {
                                        if ($category.id -eq $item.id) {
                                            $CategoryLabel = $category.name
                                            $TagCategoryLabels += [PSCustomObject]@{'Tag'=$TagLabel;'Category'=$CategoryLabel}
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            foreach ($label in $TagCategoryLabels) {
                $val = [PSCustomObject]@{'Tag'=$label.Tag;'Category'=$label.Category;'VM'=$VMLabel}
                $result += $val    
            }
        }

        $result | Out-GridView -Title "Tags associated to VMs"
    } else {
        Write-Host "VMs is not associated to any Tag" -ForegroundColor Red
        Disconnect-CisServer -Server $VIServer -Confirm:$false
        break
    }

    if ($ExportCSV) {
        if (-not (Test-Path -Path "$global:Tagging\TagQuery")) {
            New-Item -ItemType Directory -Path "$global:Tagging\TagQuery"
        }
    
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $result | Export-Csv -NoTypeInformation -Delimiter ";" -Path "$global:Tagging\TagQuery\TagsAssociatedToVMs_${timestamp}.csv"
    } 
    
    Disconnect-CisServer -Server $VIServer -Confirm:$false
}

function ListVMsAssociatedToTags() {
    param (
        [Parameter(Mandatory = $true)] [String]$VIServer,
        [Parameter(Mandatory = $true)] [String]$TagList,
        [ValidateSet("AND","OR")] [String]$TagOperator = "OR",
        [Switch]$ExportCSV
    )
    
    # Get credentials
    $Creds = $host.ui.PromptForCredential("Login to vCenter", "Please enter your user name and password.", "", "")
    
    Connect-CisServer -Server $VIServer -Credential $Creds | Out-Null

    $allTagAssociationMethodSVC = Get-CisService com.vmware.cis.tagging.tag_association -Server $VIServer

    # Loop over 15 tags and get the result.
    # If there are too many VMs and you pass in all 15 tags in one go, you may get a RESPONSE error
    if (Test-Path -Path "$TagList") {
        $FilterByTags = Get-Content $TagList
        if ($FilterByTags.lenght -gt 15) {
            Write-Host "Tags filter list is too large" -ForegroundColor Red
            break
        }
    } else {
        Write-Host "Tags filter list does not exists" -ForegroundColor Red
        break
    }
    
    $allVMs = LoadCacheVM $VIServer
    $allTags = LoadCacheTag $VIServer
    $allCategories = LoadCacheCategory $VIServer
    $allTagsxCategory = LoadCacheTagxCategory $VIServer
 
    $useTheseTags = @()
    foreach ($elem in $FilterByTags) {
        foreach ($tag in $allTags) {
            if ($elem -eq $tag.name) {
                $useTheseTags += $tag.id
            }
        }
    }

    $ObjsAssocList = @()
    $ObjsAssocList = $allTagAssociationMethodSVC.list_attached_objects_on_tags($useTheseTags)

    if ($ObjsAssocList.Count -gt 0) {
        $result = @()
        $VMCommon = @()
        foreach ($elem in $ObjsAssocList) {
            $VMLabels = @()
            foreach ($obj in $elem.object_ids) {
                if ($obj.type -eq "VirtualMachine") {
                    foreach ($vm in $allVMs) {
                        if ($vm.object.id -eq $obj.id) {
                            $VMLabels += $vm.name
                        }
                    }
                }
            }
    
            foreach ($tag in $allTags) {
                if ($tag.id -eq $elem.tag_id) {
                    $TagLabel = $tag.name
    
                    foreach ($item in $allTagsxCategory) {
                        foreach ($tagId in $item.tag) {
                            if ($tagId -eq $tag.id) {
                                foreach ($category in $allCategories) {
                                    if ($category.id -eq $item.id) {
                                        $CategoryLabel = $category.name
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            foreach ($label in $VMLabels) {
                $val = [PSCustomObject]@{'VM'=$label;'Tag'=$TagLabel;'Category'=$CategoryLabel}
                $result += $val    
            }
        }

        if ($TagOperator -eq "OR") {
            $result | Out-GridView -Title "VMs associated to Tags"
        } else {
            $VMCommon = $result | Group-Object -Property VM | Where-Object { $_.Count -eq $useTheseTags.Count } | Select-Object -Property @{Name='VM';Expression={$_.Name}}
            if ($VMCommon.Count -gt 0) {
                $VMCommon | Out-GridView -Title "Only VMs associated with all Tags"
            } else {
                Write-Host "There are not VMs associated with all Tags" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "Tags is not associated to any VM" -ForegroundColor Red
        Disconnect-CisServer -Server $VIServer -Confirm:$false
        break
    }

    if ($ExportCSV) {
        if (-not (Test-Path -Path "$global:Tagging\TagQuery")) {
            New-Item -ItemType Directory -Path "$global:Tagging\TagQuery"
        }
    
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        if ($TagOperator -eq "OR") {
            $result | Export-Csv -NoTypeInformation -Delimiter ";" -Path "$global:Tagging\TagQuery\VMsAssociatedToTags_${timestamp}.csv"
        } else {
            $VMCommon | Export-Csv -NoTypeInformation -Delimiter ";" -Path "$global:Tagging\TagQuery\OnlyVMsAssociatedToAllTags_${timestamp}.csv"
        }
    } 
    
    Disconnect-CisServer -Server $VIServer -Confirm:$false
}

function ListObjectsAssociatedToTags() {
    param (
        [Parameter(Mandatory = $true)] [String]$VIServer,
        [Parameter(Mandatory = $true)] [String]$TagList,
        [ValidateSet("AND","OR")] [String]$TagOperator = "OR",
        [ValidateSet("Cluster","ESX","Datastore","VM","All")] [String]$ObjectType = "All",
        [Switch]$ExportCSV
    )
    
    # Get credentials
    $Creds = $host.ui.PromptForCredential("Login to vCenter", "Please enter your user name and password.", "", "")
    
    Connect-CisServer -Server $VIServer -Credential $Creds | Out-Null

    $allTagAssociationMethodSVC = Get-CisService com.vmware.cis.tagging.tag_association -Server $VIServer

    # Loop over 15 tags and get the result.
    # If there are too many Objects and you pass in all 15 tags in one go, you may get a RESPONSE error
    if (Test-Path -Path "$TagList") {
        $FilterByTags = Get-Content $TagList
        if ($FilterByTags.lenght -gt 15) {
            Write-Host "Tags filter list is too large" -ForegroundColor Red
            break
        }
    } else {
        Write-Host "Tags filter list does not exists" -ForegroundColor Red
        break
    }

    $allVMs = LoadCacheVM $VIServer
    $allClusters = LoadCacheCluster $VIServer
    $allHosts = LoadCacheESX $VIServer
    $allDatastores = LoadCacheDatastore $VIServer
    $allTags = LoadCacheTag $VIServer
    $allCategories = LoadCacheCategory $VIServer
    $allTagsxCategory = LoadCacheTagxCategory $VIServer
 
    $useTheseTags = @()
    foreach ($elem in $FilterByTags) {
        foreach ($tag in $allTags) {
            if ($elem -eq $tag.name) {
                $useTheseTags += $tag.id
            }
        }
    }

    $ObjsAssocList = @()
    $ObjsAssocList = $allTagAssociationMethodSVC.list_attached_objects_on_tags($useTheseTags)

    if ($ObjsAssocList.Count -gt 0) {
        $result = @()
        $ObjCommon = @()
        foreach ($elem in $ObjsAssocList) {
            $ObjLabels = @()
            foreach ($obj in $elem.object_ids) {
                if ($ObjectType -eq "Cluster") {
                    if ($obj.type -eq "ClusterComputeResource") {
                        foreach ($cluster in $allClusters) {
                            if ($cluster.object.id -eq $obj.id) {
                                $ObjLabels += [PSCustomObject]@{'Object Name'=$cluster.name;'Object Type'=$obj.type}
                            }
                        }
                    }
                }
    
                if ($ObjectType -eq "ESX") {
                    if ($obj.type -eq "HostSystem") {
                        foreach ($esx in $allHosts) {
                            if ($esx.object.id -eq $obj.id) {
                                $ObjLabels += [PSCustomObject]@{'Object Name'=$esx.name;'Object Type'=$obj.type}
                            }
                        }
                    }
                }
    
                if ($ObjectType -eq "Datastore") {
                    if ($obj.type -eq "Datastore") {
                        foreach ($ds in $allDatastores) {
                            if ($ds.object.id -eq $obj.id) {
                                $ObjLabels += [PSCustomObject]@{'Object Name'=$ds.name;'Object Type'=$obj.type}
                            }
                        }
                    }
                }
    
                if ($ObjectType -eq "VM") {
                    if ($obj.type -eq "VirtualMachine") {
                        foreach ($vm in $allVMs) {
                            if ($vm.object.id -eq $obj.id) {
                                $ObjLabels += [PSCustomObject]@{'Object Name'=$vm.name;'Object Type'=$obj.type}
                            }
                        }
                    }
                }
    
                if ($ObjectType -eq "All") {
                    if ($obj.type -eq "ClusterComputeResource") {
                        foreach ($cluster in $allClusters) {
                            if ($cluster.object.id -eq $obj.id) {
                                $ObjLabels += [PSCustomObject]@{'Object Name'=$cluster.name;'Object Type'=$obj.type}
                            }
                        }
                    }

                    if ($obj.type -eq "HostSystem") {
                        foreach ($esx in $allHosts) {
                            if ($esx.object.id -eq $obj.id) {
                                $ObjLabels += [PSCustomObject]@{'Object Name'=$esx.name;'Object Type'=$obj.type}
                            }
                        }
                    }

                    if ($obj.type -eq "Datastore") {
                        foreach ($ds in $allDatastores) {
                            if ($ds.object.id -eq $obj.id) {
                                $ObjLabels += [PSCustomObject]@{'Object Name'=$ds.name;'Object Type'=$obj.type}
                            }
                        }
                    }

                    if ($obj.type -eq "VirtualMachine") {
                        foreach ($vm in $allVMs) {
                            if ($vm.object.id -eq $obj.id) {
                                $ObjLabels += [PSCustomObject]@{'Object Name'=$vm.name;'Object Type'=$obj.type}
                            }
                        }
                    }
                }
            }
  
            foreach ($tag in $allTags) {
                if ($tag.id -eq $elem.tag_id) {
                    $TagLabel = $tag.name
    
                    foreach ($item in $allTagsxCategory) {
                        foreach ($tagId in $item.tag) {
                            if ($tagId -eq $tag.id) {
                                foreach ($category in $allCategories) {
                                    if ($category.id -eq $item.id) {
                                        $CategoryLabel = $category.name
                                    }
                                }
                            }
                        }
                    }
                }
            }
                
            foreach ($label in $ObjLabels) {
                $val = [PSCustomObject]@{'Name'=$label."Object Name";'Type'=$label."Object Type";'Tag'=$TagLabel;'Category'=$CategoryLabel}
                $result += $val    
            }
        }

        if ($TagOperator -eq "OR") {
            $result | Out-GridView -Title "Objects associated to Tags"
        } else {
            $ObjCommon = $result | Group-Object -Property Name | Where-Object { $_.Count -eq $useTheseTags.Count } | Select-Object -Property Name
            if ($ObjCommon.Count -gt 0) {
                $ObjCommon | Out-GridView -Title "Only Objects associated with all Tags"
            } else {
                Write-Host "There are not Objects associated with all Tags" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "Tags is not associated to any Object" -ForegroundColor Red
        Disconnect-CisServer -Server $VIServer -Confirm:$false
        break
    }
    
    if ($ExportCSV) {
        if (-not (Test-Path -Path "$global:Tagging\TagQuery")) {
            New-Item -ItemType Directory -Path "$global:Tagging\TagQuery"
        }
    
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        if ($TagOperator -eq "OR") {
            $result | Export-Csv -NoTypeInformation -Delimiter ";" -Path "$global:Tagging\TagQuery\ObjectsAssociatedToTags_${timestamp}.csv"
        } else {
            $ObjCommon | Export-Csv -NoTypeInformation -Delimiter ";" -Path "$global:Tagging\TagQuery\OnlyObjectsAssociatedToAllTags_${timestamp}.csv"
        }
    }

    Disconnect-CisServer -Server $VIServer -Confirm:$false
}

function SearchTag() {
    param (
        [Parameter(Mandatory = $true)] [String]$VIServer,
        [Parameter(Mandatory = $true)] [String]$SearchString,
        [Switch]$ExportCSV
    )

    $allTags = LoadCacheTag $VIServer
    $allCategories = LoadCacheCategory $VIServer
    $allTagsxCategory = LoadCacheTagxCategory $VIServer

    $result = @()
    foreach ($tag in $allTags) {
        if ($tag.name -like "*${SearchString}*") {
            foreach ($elem in $allTagsxCategory) {
                foreach ($item in $elem.tag) {
                    if ($tag.id -eq $item) {
                        foreach ($category in $allCategories) {
                            if ($category.id -eq $elem.id) {
                                $val = [PSCustomObject]@{'Tag'=$tag.name;'Category'=$category.name}
                                $result += $val
                            }
                        }
                    }                                
                }                            
            }
        }
    }

    if ($result) {
        $result | Out-GridView -Title "Tag found"

        if ($ExportCSV) {
            if (-not (Test-Path -Path "$global:Tagging\TagQuery")) {
                New-Item -ItemType Directory -Path "$global:Tagging\TagQuery"
            }
        
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $result | Export-Csv -NoTypeInformation -Delimiter ";" -Path "$global:Tagging\TagQuery\SearchTag_${timestamp}.csv"
        }
    } else {
        Write-Host "There are no Tags that match the search criteria" -ForegroundColor Yellow
    }
}

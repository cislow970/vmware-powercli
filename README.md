# Query tag in PowerCLI

The cmdlets use a local cache of the IDs of the following objects: VM, Tag, Category, Cluster, ESX, Datastore. The cache is based on data structures in JSON format in order to speed up the queries, limiting the interaction with the vCenter to the only request of the "Tag - Object" associations.

# Loading cmdlets

To run the cmdlets, after downloading the ***Tag.ps1*** file, its contents must be loaded into memory:

1. Install the latest release of the PowerCLI from the Powershell Gallery. 

2. Open Powershell and go to the folder where the ***Tag.ps1*** file was saved.

3. Run the following command to load the cmdlets into memory: **. .\Tag.ps1**

# Usage cmdlets

Each cmdlet requires the insertion of valid credentials to authenticate to the vCenter where one of the operations indicated below is to be performed. Cache refresh cmdlets should only be used when it is assumed that the content of the vCenter may have changed due to the creation of new objects and new associations.

It is necessary to define a working directory, for example "C:\Tagging", where to save the cache and the results of the queries. It must be mapped at the head of the ***Tag.ps1*** file:

``$global:Tagging = "C:\Tagging"``

The cache is created in the "TagCache" folder within the working directory defined above.
The exports in CSV format are saved in the "TagQuery" folder in the working directory defined above.

(*) = mandatory option

1. ***RefreshCacheVM*** Make the local cache of virtual machine IDs.

	1. Cmdlet options:
	- -VIServer: vCenter to work on (*)  

	2. Examples:
	- ``RefreshCacheVM -VIServer vc.domain.local``

2. ***RefreshCacheCluster*** Make the local cache of cluster IDs.

	1. Cmdlet options:
	- -VIServer: vCenter to work on (*)  

	2. Examples:
	- ``RefreshCacheCluster -VIServer vc.domain.local``

3. ***RefreshCacheESX*** Make the local cache of ESX IDs.

	1. Cmdlet options:
	- -VIServer: vCenter to work on (*)  

	2. Examples:
	- ``RefreshCacheESX -VIServer vc.domain.local``

4. ***RefreshCacheDatastore*** Make the local cache of datastore IDs.

	1. Cmdlet options:
	- -VIServer: vCenter to work on (*)  

	2. Examples:
	- ``RefreshCacheDatastore -VIServer vc.domain.local``

5. ***RefreshCacheTag*** Make the local cache of tag IDs.

	1. Cmdlet options:
	- -VIServer: vCenter to work on (*)  

	2. Examples:
	- ``RefreshCacheTag -VIServer vc.domain.local``

6. ***RefreshCacheCategory*** Make the local cache of category IDs.

	1. Cmdlet options:
	- -VIServer: vCenter to work on (*)  

	2. Examples:
	- ``RefreshCacheCategory -VIServer vc.domain.local``

7. ***RefreshCacheTagxCategory*** Make the local cache of Tag IDs for each Category.

	1. Cmdlet options:
	- -VIServer: vCenter to work on (*)  

	2. Examples:
	- ``RefreshCacheTagxCategory -VIServer vc.domain.local``

8. ***ListTagsAssociatedToVM*** Lists all tags associated with the specified virtual machine.

	1. Cmdlet options:
	- -VIServer: vCenter to work on (*)
	- -VMName: Name of the virtual machine to search for associated tags (*)
	- -ExportCSV: Save the result in CSV file  

	2. Examples:
	- ``ListTagsAssociatedToVM -VIServer vc.domain.local -VMName 02SRV00H6X``
	- ``ListTagsAssociatedToVM -VIServer vc.domain.local -VMName 02SRV00H6X -ExportCSV``

9. ***ListVMsAssociatedToTag*** Lists all virtual machines associated with the specified tag.

	1. Cmdlet options:
	- -VIServer: vCenter to work on (*)
	- -TagName: Name of the tag to search for associated virtual machines (*)
	- -ExportCSV: Save the result in CSV file  

	2. Examples:
	- ``ListVMsAssociatedToTag -VIServer vc.domain.local -TagName "SA"``
	- ``ListVMsAssociatedToTag -VIServer vc.domain.local -TagName "SA" -ExportCSV``

10. ***ListTagsAssociatedToVMs*** Lists the tags associated with the specified virtual machine list. The names of the virtual machines to be queried must be entered in a TXT file, one for each row.

	1. Cmdlet options:
	- -VIServer: vCenter to work on (*)
	- -VMList: File containing the list of virtual machines to search for associated tags **(MAX 2000 VMs)** (*)
	- -ExportCSV: Save the result in CSV file  

	2. Examples:
	- ``ListTagsAssociatedToVMs -VIServer vc.domain.local -VMList "C:\Temp\vmlist.txt"``
	- ``ListTagsAssociatedToVMs -VIServer vc.domain.local -VMList "C:\Temp\vmlist.txt" -ExportCSV``

11. ***ListVMsAssociatedToTags*** Lists the virtual machines associated with the specified tag list. The names of the tags to be queried must be placed in a TXT file, one for each row.

	1. Cmdlet options:
	- -VIServer: vCenter to work on (*)
	- -TagList: File containing the list of tags to search for associated virtual machines. **(MAX 15 Tags)** (*)
	- -TagOperator: If specified with value AND ***(different from default value OR)*** then the result will consist only of the virtual machines that have all the tags in the list in common **(allowed values: OR | AND)**
	- -ExportCSV: Save the result in CSV file  

	2. Examples:
	- ``ListVMsAssociatedToTags -VIServer vc.domain.local -TagList "C:\Temp\taglist.txt"``
	- ``ListVMsAssociatedToTags -VIServer vc.domain.local -TagList "C:\Temp\taglist.txt" -ExportCSV``
	- ``ListVMsAssociatedToTags -VIServer vc.domain.local -TagList "C:\Temp\taglist.txt" -TagOperator AND``
	- ``ListVMsAssociatedToTags -VIServer vc.domain.local -TagList "C:\Temp\taglist.txt" -TagOperator AND -ExportCSV``

12. ***ListObjectsAssociatedToTags*** Lists the objects of a given type associated with the specified tag list. The names of the tags to be queried must be placed in a TXT file, one for each row.

	1. Cmdlet options:
	- -VIServer: vCenter to work on (*)
	- -TagList: File containing the list of tags to search for associated virtual machines. **(MAX 15 Tags)** (*)
	- -TagOperator: If specified with value AND ***(different from default value OR)*** then the result will consist only of the objects that have all the tags in the list in common **(allowed values: OR | AND)**
	- -ObjectType: Type of object on which to search for association with the tags specified in the list **(allowed values: Cluster | ESX | Datastore | VM | All)** (*)
	- -ExportCSV: Save the result in CSV file  

	2. Examples:
	- ``ListObjectsAssociatedToTags -VIServer vc.domain.local -TagList "C:\Temp\taglist.txt" -ObjectType Datastore``
	- ``ListObjectsAssociatedToTags -VIServer vc.domain.local -TagList "C:\Temp\taglist.txt" -ObjectType ESX``
	- ``ListObjectsAssociatedToTags -VIServer vc.domain.local -TagList "C:\Temp\taglist.txt" -ObjectType All``
	- ``ListObjectsAssociatedToTags -VIServer vc.domain.local -TagList "C:\Temp\taglist.txt" -ObjectType All -ExportCSV``
	- ``ListObjectsAssociatedToTags -VIServer vc.domain.local -TagList "C:\Temp\taglist.txt" -TagOperator AND -ObjectType All``
	- ``ListObjectsAssociatedToTags -VIServer vc.domain.local -TagList "C:\Temp\taglist.txt" -TagOperator AND -ObjectType All -ExportCSV``

13. ***SearchTag*** cerca tutti i tag che contengono la stringa indicata (utilizzo cache implicito). 

	1. Cmdlet options:
	- -VIServer: vCenter to work on (*)
	- -SearchString: String to search for (*)
	- -ExportCSV: Save the result in CSV file  

	2. Examples:
	- ``SearchTag -VIServer vc.domain.local -SearchString "AUTOMATION"``
	- ``SearchTag -VIServer vc.domain.local -SearchString "AUTOMATION" -ExportCSV``


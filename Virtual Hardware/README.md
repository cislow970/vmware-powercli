# Get current and maximum reachable vHW for each VM.

References:  
* [ESXi Build numbers and versions - KB 2143832](https://kb.vmware.com/s/article/2143832)
* [Virtual Hardware Version - KB 1003746](https://kb.vmware.com/s/article/1003746)
  
  
| Product | Major release |	Build Number | Release Date | vHW Version |
| :--- | :--- | :--- | :--- | :--- |
| ESXi 7.0 U1 (7.0.1) |	7.0.0 | 16850804 | 10/06/2020 | vmx-18 |
| ESXi 7.0 (7.0.0) | 7.0.0 | 15843807 |	04/02/2020 | vmx-17 |
| ESXi 6.7 U2 |	6.7.0 |	13006603 | 04/11/2019 | vmx-15 |
| ESXi 6.7 | 6.7.0 | 8169922 | 04/17/2018 | vmx-14 |
| ESXi 6.5 | 6.5.0 | 4564106 | 11/15/2016 | vmx-13 |
| ESXi 6.0 | 6.0.0 | 2494585 | 03/12/2015 | vmx-11 |
| ESXi 5.5 | 5.5.0 | 1331820 | 09/22/2013 | vmx-10 |
| ESXi 5.1 | 5.1.0 | 799733	| 09/10/2012 | vmx-09 |
| ESXi 5.0 | 5.0.0 | 469512 | 08/24/2011 | vmx-08 |


Example:
1. Connect to vCenter:
	* Connect-VIServer <your_vcenter>
	
2. Get vHW report for each VM in the vCenter:
	* vmware-vhw-report.ps1 -Save C:\Temp\\<your_vcenter>.csv


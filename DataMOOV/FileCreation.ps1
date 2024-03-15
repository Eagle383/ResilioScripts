Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1

Get-ChildItem "\\labnet.local\prod_site\Production_Folders" | Remove-Item
Get-ChildItem "\\labnet.local\Dr_site\Production_Folders" | Remove-Item

$count = 0
do
{
$count = (Get-ChildItem "\\labnet.local\Dr_site\Production_Folders").count

sleep -Milliseconds 10
Clear-Host
Write-Host Starting

Write-Host $count
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 262144 -Maximum 524288)  -Extension .pdf -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1024 -Maximum 4096) -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .vhd -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .docx -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .xlsx -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .ppt -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .html -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .csv -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .png -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .jpg -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .zip -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .rtf -NoRandomData -RandomFileNameGUID -NoClobber}

Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 262144 -Maximum 524288)  -Extension .pdf -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1024 -Maximum 4096) -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .vhd -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .docx -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .xlsx -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .ppt -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .html -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .csv -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .png -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .jpg -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .zip -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Production_Folders" -Count 1000 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .rtf -NoRandomData -RandomFileNameGUID -NoClobber}

Write-Host End
$count = (Get-ChildItem "\\labnet.local\prod_site\Production_Folders").count
Write-Host $count
$removejob = Get-Job -State Completed
$removejob | Remove-Job
sleep -Seconds 300
$count = (Get-ChildItem "\\labnet.local\prod_site\Production_Folders").count

}
while ($count -le '1000')
Get-ChildItem "\\labnet.local\prod_site\Production_Folders\.sync\Archive" | Remove-Item
Get-ChildItem "\\labnet.local\Dr_site\Production_Folders\.sync\Archive" | Remove-Item

do
{
$removejob = Get-Job -State Completed
$removejob | Remove-Job
Get-Job
$jobcount = ((Get-Job).count)
Write-Host $jobcount
sleep -Seconds 1
Clear-Host
}
while ($jobcount -gt "0")


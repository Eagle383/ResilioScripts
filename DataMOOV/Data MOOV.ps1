Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1

$count = 0
do
{
$count = (Get-ChildItem "\\labnet.local\Dr_site\Production_Folders").count

sleep -Milliseconds 10

if ((Get-ChildItem "\\labnet.local\prod_site\Misc_Data").count -ge "1000")
{
Get-ChildItem "\\labnet.local\prod_site\Misc_Data" | Select-Object -First 500 | Remove-Item
}

if ((Get-ChildItem "\\labnet.local\prod_site\Misc_Data").count -ge "3000")
{
Get-ChildItem "\\labnet.local\prod_site\Misc_Data" | Remove-Item
}

Clear-Host
Write-Host Starting

Write-Host $count
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 262144 -Maximum 524288)  -Extension .pdf -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1024 -Maximum 4096) -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .vhd -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .docx -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .xlsx -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .ppt -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .html -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .csv -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .png -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .jpg -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .zip -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\prod_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .rtf -NoRandomData -RandomFileNameGUID -NoClobber}

Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 262144 -Maximum 524288)  -Extension .pdf -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1024 -Maximum 4096) -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .vhd -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .docx -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .xlsx -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .ppt -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .html -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .csv -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .png -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .jpg -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .zip -NoRandomData -RandomFileNameGUID -NoClobber}
Start-Job -ScriptBlock {Import-Module C:\Users\netadmin\Desktop\Scripts\Filecreation_module.psm1; New-RandomData -Path "\\labnet.local\Dr_site\Misc_Data" -Count 5 -Size (Get-Random -Minimum 1048576 -Maximum 5242880) -Extension .rtf -NoRandomData -RandomFileNameGUID -NoClobber}

Write-Host End
$count = (Get-ChildItem "\\labnet.local\prod_site\Misc_Data").count
Write-Host $count
$removejob = Get-Job -State Completed
$removejob | Remove-Job
sleep -Seconds 120
$count = (Get-ChildItem "\\labnet.local\prod_site\Misc_Data").count

Get-ChildItem "\\labnet.local\prod_site\Misc_Data" | Select-Object -First 10 | Remove-Item
if ((Get-ChildItem "\\labnet.local\prod_site\Misc_Data").count -ge "1000")
{
Get-ChildItem "\\labnet.local\prod_site\Misc_Data" | Select-Object -First 500 | Remove-Item
}
Get-ChildItem "\\labnet.local\Dr_site\Misc_Data\.sync\Archive" | Remove-Item
Get-ChildItem "\\labnet.local\prod_site\Misc_Data\.sync\Archive" | Remove-Item

}
while ($count -le '5000')

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


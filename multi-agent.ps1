[CmdletBinding()]
param
(
    [int]$AgentCount = -1,
    [switch]$DontStartService
)

<#
.SYNOPSIS
The script is intended to spin up additional agents on the current system or remove them if they are no longer needed.

.DESCRIPTION
The script creates extra syncX.conf files in the primary agent installation folder and extra storage folders, 
and it also creates extra services and starts them. The script must be started under an administrator account 
(elevated privileges). The storage paths will be either %ProgramData%\Resilio\Connect Agent X or a path specified 
in the sync.conf parameter storage_path. When removing extra agents, the script will clean up the storage folder 
and syncX.conf file. That may fail if the service does not stop gracefully.

.PARAMETER AgentCount
Sets the desired agent count. If the actual amount is lesser, the script will spin up additional ones. 
If the actual amount is greater, the script will remove the extras. If set to -1, it will just show the 
existing amount of agents. The AgentCount cannot be lesser than the number of agents installed via MSI. 
For example, if you have the Management Console installed via MSI and one Agent installed via MSI, the script 
won't be able to reduce the number of agents below 2.

.PARAMETER DontStartService
Sets the parameter to prevent the script from starting up extra agent services after creation.

.LINK
https://github.com/resilio-inc/connect-scripts/tree/master/Multiple%20Agents
#>

$ActualAgentCount = 0
$NonRemovableAgentCount = 0

$tmp = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Resilio Inc.\Resilio Connect Console\' -ErrorAction SilentlyContinue
if ($tmp) {
    $AgentExecutable = "$($tmp.InstallDir)\agent\Resilio Connect Agent.exe"
    $ConfigPath = "$env:ProgramData\Resilio\Connect Server\sync.conf"
    $NonRemovableAgentCount++
    $ActualAgentCount++
}

$tmp = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Resilio, Inc.\Resilio Connect Agent\' -ErrorAction SilentlyContinue
if ($tmp) {
    $AgentExecutable = "$($tmp.InstallDir)\Resilio Connect Agent.exe"
    $ConfigPath = "$($tmp.InstallDir)\sync.conf"
    $NonRemovableAgentCount++
}

$services = Get-Service -Name "connectsvc*" -ErrorAction SilentlyContinue
$ActualAgentCount += $services.Count

if ($AgentCount -eq -1) {
    Write-Host "Total agents running on the system: $ActualAgentCount"
    exit 0
}

# Verify PowerShell version
if ($PSVersionTable.PSVersion -lt [Version]"5.1") {
    throw "PowerShell must be version 5.1 or newer."
}

# Verify config existence
if (-not [System.IO.File]::Exists($ConfigPath)) {
    throw "Config file not found: `"$ConfigPath`"."
}

# Verify elevated privileges
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "The script is not running with elevated privileges. Adding/removing agents is not possible."
}

# Add agents
if ($AgentCount -gt $ActualAgentCount) {
    $AgentsToCreate = $AgentCount - $ActualAgentCount
    $AgentIndex = $ActualAgentCount + 1
    Write-Host "Creating $AgentsToCreate additional agent service(s)."

    for ($i = $AgentIndex; $i -lt ($AgentIndex + $AgentsToCreate); $i++) {
        $NewConfigPath = "$(Split-Path $ConfigPath)\sync$i.conf"
        $syncConf = Get-Content $ConfigPath | ConvertFrom-Json

        Update-SyncConfig -syncConf $syncConf -i $i -BaseName $BaseName -BaseStoragePath $BaseStoragePath -NewConfigPath $NewConfigPath

        Register-Service -AgentExecutable $AgentExecutable -i $i -NewConfigPath $NewConfigPath -DontStartService $DontStartService
    }

    Write-Host "Additional services created. Exiting script."
    exit 0
}

# Remove agents
if ($AgentCount -lt $ActualAgentCount) {
    Remove-ExtraAgents -AgentCount $AgentCount -ActualAgentCount $ActualAgentCount -NonRemovableAgentCount $NonRemovableAgentCount -ConfigPath $ConfigPath
}

if ($AgentCount -eq $ActualAgentCount) {
    Write-Host "$ActualAgentCount agents run on this system. No changes needed. Exiting script."
    exit 0
}

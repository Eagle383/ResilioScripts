Add-Type -AssemblyName System.Windows.Forms

######################## Ignoring cert check error callback #####################
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
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Ssl3, [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12
####################################################################################


# Ask the user if they want to export a CSV template
$exportTemplate = Read-Host "Would you like to export a CSV template? (yes/no)"

if ($exportTemplate.ToLower() -eq 'yes') {
    # Initialize Save File Dialog
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.InitialDirectory = [Environment]::GetFolderPath("Desktop")
    $saveFileDialog.Filter = "CSV files (*.csv)|*.csv"
    $saveFileDialog.FileName = "sync_job_template.csv"
    
    $dialogResult = $saveFileDialog.ShowDialog()

    if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
        # CSV template content with path columns but without values
        $csvTemplate = "JobName,JobDescription,AgentNames,Permission,winPath,linuxPath,osxPath`r`n" +
                       "Sync Job 1,Description for Sync Job 1,Agent1,rw,,," + "`r`n" +
                       "Sync Job 1,Description for Sync Job 1,Agent2,sro,,,"

        # Export the template CSV
        $csvTemplate | Out-File -FilePath $saveFileDialog.FileName -Encoding UTF8
        Write-Host "CSV template exported to $($saveFileDialog.FileName)"
    }
    
    # Exit the script after exporting the template
    exit
}

# Ask the user if they would like to select a CSV for importing job details
$importCSV = Read-Host "Would you like to select a CSV file for importing job details? (yes/no)"

if ($importCSV.ToLower() -eq 'yes') {
    # Configure OpenFileDialog
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.InitialDirectory = [Environment]::GetFolderPath("Desktop")
    $openFileDialog.Filter = "CSV files (*.csv)|*.csv"
    $openFileDialog.ShowDialog() | Out-Null

    # Get the selected CSV file path
    $csvPath = $openFileDialog.FileName

    if (-not [string]::IsNullOrWhiteSpace($csvPath)) {
        # Prompt user for Management Console host and API token
        $MCHost = Read-Host "Please enter the Management Console host (including https:// and port)"
        $APIToken = Read-Host "Please enter your API token"

        # Prompt user to select the job type
        $jobTypes = @("consolidation", "distribution", "script", "sync") | Sort-Object
        Write-Host "Select the job type by entering the corresponding number:"
        $jobTypes.ForEach({
            $index = [Array]::IndexOf($jobTypes, $_) + 1
            Write-Host "${index}: $_"
        })
        [int]$jobTypeSelection = Read-Host "Enter number"
        while ($jobTypeSelection -lt 1 -or $jobTypeSelection -gt $jobTypes.Length) {
            Write-Host "Invalid selection. Please enter a number between 1 and $($jobTypes.Length)."
            [int]$jobTypeSelection = Read-Host "Enter number"
        }
        $jobType = $jobTypes[$jobTypeSelection - 1]

        # Prompt user to select the job profile
        $jobProfiles = Invoke-RestMethod -Method GET -Uri "$MCHost/api/v2/job_profiles" -Headers @{ "Authorization" = "Token $APIToken" }
        Write-Host "Please select a job profile by entering the corresponding number:"
        for ($i = 0; $i -lt $jobProfiles.Count; $i++) {
            Write-Host "$($i + 1): $($jobProfiles[$i].name)"
        }
        [int]$profileNumber = Read-Host "Enter number"
        while ($profileNumber -lt 1 -or $profileNumber -gt $jobProfiles.Count) {
            Write-Host "Invalid selection. Please enter a number between 1 and $($jobProfiles.Count)."
            [int]$profileNumber = Read-Host "Enter number"
        }
        $selectedProfile = $jobProfiles[$profileNumber - 1]

        # Analyze profile settings to determine if reference agent is needed
        $profileSettings = $selectedProfile.settings
        $referenceAgentID = $null
        if ($profileSettings -and ($profileSettings.windows_fs_acl_mode -ne $null -or $profileSettings.posix_fs_acl_mode -ne $null) -and
            ($profileSettings.windows_fs_acl_mode -ne 0 -or $profileSettings.posix_fs_acl_mode -ne 0)) {
            # Fetch agent ID based on agent name
            $referenceAgentName = Read-Host "Please enter the reference agent computer name"
            $agentList = Invoke-RestMethod -Method GET -Uri "$MCHost/api/v2/agents" -Headers @{ "Authorization" = "Token $APIToken" }
            $referenceAgent = $agentList | Where-Object { $_.name -eq $referenceAgentName }
            if ($referenceAgent) {
                $referenceAgentID = $referenceAgent.id
            } else {
                Write-Host "Reference agent '$referenceAgentName' not found."
            }
        }

        # Define base URL and headers for API requests using "Token" for authorization
        $base_url = "$MCHost/api/v2"
        $http_headers = @{
            "Authorization" = "Token $APIToken"
        }

        # Fetch the list of all agents from the API
        $agent_list = Invoke-RestMethod -Method GET -uri "$base_url/agents" -Headers $http_headers -ContentType "Application/json"

        $jobEntries = Import-Csv $csvPath
        $uniqueJobNames = $jobEntries | Select-Object -ExpandProperty JobName -Unique

        foreach ($jobName in $uniqueJobNames) {
            $currentJobEntries = $jobEntries | Where-Object { $_.JobName -eq $jobName }
            $jobDescription = $currentJobEntries[0].JobDescription

            $agents = @()
            foreach ($entry in $currentJobEntries) {
                $agentName = $entry.AgentNames
                $permission = $entry.Permission
                $agent = $agent_list | Where-Object { $_.name -eq $agentName }

                if ($agent) {
                    $agents += @{
                        id = $agent.id
                        permission = $permission
                        path = @{
                            linux = $entry.linuxPath
                            win = $entry.winPath
                            osx = $entry.osxPath
                        }
                    }
                } else {
                    Write-Host "Agent '$agentName' not found."
                }
            }

            # Remove the 'groups' section for sync jobs and add agents directly
            $JobObject = @{
                name = $jobName
                description = $jobDescription
                type = $jobType
                agents = $agents
                use_new_cipher = $false
                settings = @{
                    priority = 5
                    use_ram_optimization = $true
                    reference_agent_id = $referenceAgentID
                }
                profile_id = $selectedProfile.id
            }

            # Convert job object to JSON
            $JSON = $JobObject | ConvertTo-Json -Depth 10

            # Check and create C:\tmp directory if it doesn't exist
            if (-not (Test-Path -Path 'C:\tmp')) {
                New-Item -ItemType Directory -Path 'C:\tmp'
            }

            # Export the job JSON to a file
            $jsonFilePath = "C:\tmp\$($jobName).json"
            $JSON | Out-File -FilePath $jsonFilePath -Force
            Write-Host "Job '$jobName' JSON exported to $jsonFilePath"

            # Invoke job creation API call
            try {
                $response = Invoke-RestMethod -Method "POST" -Uri "$base_url/jobs" -Headers $http_headers -ContentType "Application/json" -Body $JSON
                $responseJson = $response | ConvertTo-Json -Depth 10
                $responsePath = "C:\tmp\$($jobName)_response.json"
                $responseJson | Out-File -FilePath $responsePath -Force
                Write-Host "Job '$jobName' created successfully. Response saved to $responsePath"
            } catch {
                Write-Host "Error creating job '$jobName': $($_.Exception.Message)"
            }
        }
    } else {
        Write-Host "No CSV file was selected."
    }
} else {
    Write-Host "Exporting a CSV template was skipped."
}

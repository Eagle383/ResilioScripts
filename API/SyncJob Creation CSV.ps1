Add-Type -AssemblyName System.Windows.Forms

# Ask the user if they want to export a CSV template
$exportTemplate = Read-Host "Would you like to export a CSV template? (yes/no)"

if ($exportTemplate.ToLower() -eq 'yes') {
    # Initialize Save File Dialog
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.InitialDirectory = [Environment]::GetFolderPath("Desktop")
    $saveFileDialog.Filter = "CSV files (*.csv)|*.csv"
    $saveFileDialog.FileName = "template.csv"
    
    $dialogResult = $saveFileDialog.ShowDialog()

    if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
        # Correct CSV template content
        $csvTemplate = "JobName,JobDescription,AgentNames,winPath,linuxPath,osxPath`r`n" +
                       "Job 1,Description for Job 1,Agent1,C:\tmp\job1,,`r`n" +
                       "Job 1,Description for Job 1,Agent2,C:\tmp\job1,,`r`n" +
                       "Job 2,Description for Job 2,Agent1,C:\tmp\job2,,`r`n" +
                       "Job 2,Description for Job 2,Agent2,C:\tmp\job2,,`r`n" +
                       "Job 3,Description for Job 3,Agent1,C:\tmp\job3,,`r`n" +
                       "Job 3,Description for Job 3,Agent2,C:\tmp\job3,,"

        # Export the template CSV
        $csvTemplate | Out-File -FilePath $saveFileDialog.FileName -Force
        Write-Host "CSV template exported to $($saveFileDialog.FileName)"
    }
    
    # Exit the script
    exit
}

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
    
    # Define job types and prompt user to select one
    $jobTypes = @("distribution", "consolidation", "sync") | Sort-Object
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

        $selectedAgents = @()
        foreach ($entry in $currentJobEntries) {
            $agentName = $entry.AgentNames
            $agent = $agent_list | Where-Object { $_.name -eq $agentName }

            if ($agent) {
                $winPath = $entry.winPath
                $linuxPath = $entry.linuxPath
                $osxPath = $entry.osxPath

                $selectedAgents += [PSCustomObject]@{
                    id = $agent.id
                    path = @{
                        linux = $linuxPath
                        win = $winPath
                        osx = $osxPath
                    }
                }
            } else {
                Write-Host "Agent '$agentName' not found."
            }
        }

        $JobObject = [PSCustomObject]@{
            name = $jobName
            description = $jobDescription
            type = $jobType
            settings = @{ use_ram_optimization = $true }
            profile_id = 2
            agents = $selectedAgents
        }

        $JSON = $JobObject | ConvertTo-Json -Depth 10

        # Check and create C:\tmp directory if it doesn't exist
        if (-not (Test-Path -Path 'C:\tmp')) {
            New-Item -ItemType Directory -Path 'C:\tmp'
        }

        # Invoke job creation API call
        try {
            $response = Invoke-RestMethod -Method "POST" -Uri "$base_url/jobs" -Headers $http_headers -ContentType "Application/json" -Body $JSON
            $responseJson = $response | ConvertTo-Json -Depth 10
            $responsePath = "C:\tmp\$($jobName).json"
            $responseJson | Out-File -FilePath $responsePath -Force
            Write-Host "Job '$jobName' created successfully. Response saved to $responsePath"
        } catch {
            Write-Host "Error creating job '$jobName': $($_.Exception.Message)"
        }
    }
} else {
    Write-Host "No CSV file was selected."
}
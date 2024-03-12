Add-Type -AssemblyName System.Windows.Forms

# Configure OpenFileDialog
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.initialDirectory = [Environment]::GetFolderPath("Desktop")
$openFileDialog.filter = "CSV files (*.csv)|*.csv"
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
    $jobTypes.ForEach({ $index = [Array]::IndexOf($jobTypes, $_) + 1; Write-Host "$index: $_" })
    $jobTypeSelection = Read-Host "Enter number"
    while ($jobTypeSelection -lt 1 -or $jobTypeSelection -gt $jobTypes.Length) {
        Write-Host "Invalid selection. Please enter a number between 1 and ${jobTypes.Length}."
        $jobTypeSelection = Read-Host "Enter number"
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
                $linuxPath = ""
                $windowsPath = $entry.winPath
                $macPath = ""

                $selectedAgents += [PSCustomObject]@{
                    id = $agent.id
                    permission = "rw"
                    path = @{
                        linux = $linuxPath
                        win = $windowsPath
                        osx = $macPath
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

        # Invoke job creation API call
        try {
            $response = Invoke-RestMethod -Method "POST" -Uri "$base_url/jobs" -Headers $http_headers -ContentType "Application/json" -Body $JSON
            Write-Host "Job '$jobName' created successfully."
        } catch {
            Write-Host "Error creating job '$jobName': $_"
        }
    }
} else {
    Write-Host "No CSV file was selected."
}

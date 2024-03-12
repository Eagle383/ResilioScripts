Add-Type -AssemblyName System.Windows.Forms

# Create and configure OpenFileDialog
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
    $jobTypes = @("distribution", "consolidation", "script", "sync")
    Write-Host "Select the job type by entering the corresponding number:"
    for ($i = 0; $i -lt $jobTypes.Length; $i++) {
        Write-Host "$($i + 1): $($jobTypes[$i])"
    }
    $jobTypeSelection = Read-Host "Enter number (1-4)"
    while ($jobTypeSelection -lt 1 -or $jobTypeSelection -gt $jobTypes.Length) {
        Write-Host "Invalid selection. Please enter a number between 1 and 4."
        $jobTypeSelection = Read-Host "Enter number (1-4)"
    }
    $jobType = $jobTypes[$jobTypeSelection - 1]

    # Import the job entries from the selected CSV file
    $jobEntries = Import-Csv $csvPath

    # Define base URL and headers for API requests using "Token" for authorization
    $base_url = "$MCHost/api/v2"
    $http_headers = @{
        "Authorization" = "Token $APIToken"
    }

    # Fetch the list of all agents from the API
    try {
        $agent_list = Invoke-RestMethod -Method GET -uri "$base_url/agents" -Headers $http_headers -ContentType "Application/json"
    } catch {
        Write-Host "Error fetching agents: $_"
        exit
    }

    $uniqueJobNames = $jobEntries | Select-Object -ExpandProperty JobName -Unique

    foreach ($jobName in $uniqueJobNames) {
        $currentJobEntries = $jobEntries | Where-Object { $_.JobName -eq $jobName }
        $jobDescription = $currentJobEntries[0].JobDescription  # Assuming description is consistent

        $selectedAgents = @()

        foreach ($entry in $currentJobEntries) {
            $agentName = $entry.AgentNames
            $agent = $agent_list | Where-Object { $_.name -eq $agentName }

            if ($agent) {
                # Initialize and assign paths
                $linuxPath = ""
                $windowsPath = ""
                $macPath = ""

                switch ($agent.os) {
                    {$_ -like "*win*"} { $windowsPath = $entry.winPath }
                    {$_ -like "*linux*"} { $linuxPath = $entry.linuxPath }
                    {$_ -like "*mac*" -or $_ -like "*osx*"} { $macPath = $entry.osxPath }
                }

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
            name        = $jobName
            description = $jobDescription
            type        = $jobType
            settings    = @{ use_ram_optimization = $true }
            profile_id  = 2
            agents      = $selectedAgents
        }

        $JSON = $JobObject | ConvertTo-Json -Depth 10
        Write-Output $JSON

        try {
            Invoke-RestMethod -Method "POST" -Uri "$base_url/jobs" -Headers $http_headers -ContentType "Application/json" -Body $JSON
        } catch {
            Write-Host "Error creating job: $_"
        }
    }
} else {
    Write-Host "No CSV file was selected."
}

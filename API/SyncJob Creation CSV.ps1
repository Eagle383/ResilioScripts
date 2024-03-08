# Prompt user for Management Console host and API token
$MCHost = Read-Host "Please enter the Management Console host (including https:// and port)"
$APIToken = Read-Host "Please enter your API token"

# Prompt user for job details and agent names
$jobName = Read-Host "Please enter the job name"
$jobDescription = Read-Host "Please enter the job description"

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

$agentNamesInput = Read-Host "Please enter the agent names separated by commas"

# Parse agent names
$agentNames = $agentNamesInput.Split(',') | ForEach-Object { $_.Trim() }

# Define base URL and headers for API requests using "Token" for authorization
$base_url = "$MCHost/api/v2"
$http_headers = @{
    "Authorization" = "Token $APIToken"
}

# Fetch the list of agents from the API
try {
    $agent_list = Invoke-RestMethod -Method GET -uri "$base_url/agents" -Headers $http_headers -ContentType "Application/json"
} catch {
    Write-Host "Error fetching agents: $_"
    exit
}

# Find selected agents and prompt for OS-specific paths
$selectedAgents = @()
foreach ($agentName in $agentNames) {
    $agent = $agent_list | Where-Object { $_.name -eq $agentName }
    if ($agent) {
        Write-Host "Agent: $($agent.name) - OS: $($agent.os)"
        $linuxPath = $null
        $windowsPath = $null
        $macPath = $null

        # Check the OS and prompt for the corresponding path
        if ($agent.os -like "*win*") {
            $windowsPath = Read-Host "Please enter the Windows sync path for $($agent.name)"
        } elseif ($agent.os -like "*linux*") {
            $linuxPath = Read-Host "Please enter the Linux sync path for $($agent.name)"
        } elseif ($agent.os -like "*mac*" -or $agent.os -like "*osx*") {
            $macPath = Read-Host "Please enter the macOS sync path for $($agent.name)"
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

# Build the JobObject with user-specified paths
$JobObject = [PSCustomObject]@{
    name        = $jobName
    description = $jobDescription
    type        = $jobType
    settings    = @{
        use_ram_optimization = $true
        reference_agent_id   = 400 # This should be dynamically set or verified
    }
    profile_id = 2
    agents     = $selectedAgents
}

# Convert JobObject to JSON
$JSON = $JobObject | ConvertTo-Json -Depth 10

# Output the JSON for review
Write-Output $JSON

# Create the job via API
try {
    Invoke-RestMethod -Method "POST" -Uri "$MCHost/api/v2/jobs" -Headers @{ "Authorization" = "Token $APIToken" } -ContentType "Application/json" -Body $JSON
} catch {
    Write-Host "Error creating job: $_"
}
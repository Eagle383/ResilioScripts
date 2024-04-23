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

# Hardcoded importCSV, MCHost, APIToken, and csvPath
$importCSV = "yes"
$MCHost = "https://192.168.2.8:8446"
$APIToken = "NL2X6L25T46FYAAMZOXUQVRQCDJ7DTXQOCOVUT3RALHDV4NMOG4Q"
$csvPath = "C:\Users\eagle\OneDrive\Documents\GitHub\ResilioScripts\API\Dist_Job_template.csv"
$outputPath = "C:\TMP"  # Output path for JSON responses

# Hardcoded scheduler variables
$schedulerType = "minutes"
$schedulerEvery = 55  # Example interval

if ($importCSV.ToLower() -eq 'yes') {
    if (-not [string]::IsNullOrWhiteSpace($csvPath)) {
        # Validate Management Console host and API token
        if ([string]::IsNullOrWhiteSpace($APIToken) -or [string]::IsNullOrWhiteSpace($MCHost)) {
            Write-Host "API Token and Management Console host must be provided."
            exit
        }

        # Import job details from the selected CSV file
        $jobEntries = Import-Csv $csvPath

        # Group job entries by JobName
        $groupedJobEntries = $jobEntries | Group-Object JobName

        foreach ($group in $groupedJobEntries) {
            $currentJobName = $group.Name
            $currentJobEntries = $group.Group

            # Extract job details from the first entry in the group
            $jobDescription = $currentJobEntries[0].JobDescription
            $jobType = $currentJobEntries[0].JobType

            # Define agents array for the current job
            $agentsArray = @()

            foreach ($entry in $currentJobEntries) {
                $agentName = $entry.AgentNames
                $permission = $entry.Permission
                $winPath = $entry.winPath
                $linuxPath = $entry.linuxPath
                $osxPath = $entry.osxPath

                # Fetch agent details or ID based on agent name from API
                $agent = Invoke-RestMethod -Method GET -Uri "$MCHost/api/v2/agents?name=$agentName" -Headers @{ "Authorization" = "Token $APIToken" }
                if ($agent) {
                    $agentID = $agent.id

                    # Construct agent object and add to agents array
                    $agentObject = @{
                        id = $agentID
                        permission = $permission
                        path = @{
                            win = $winPath
                            linux = $linuxPath
                            osx = $osxPath
                        }
                    }

                    $agentsArray += $agentObject
                } else {
                    Write-Host "Agent '$agentName' not found."
                }
            }

            # Define the job object with scheduler included if applicable
            $jobObject = @{
                name = $currentJobName
                description = $jobDescription
                type = $jobType
                agents = $agentsArray
                scheduler = @{
                    type = $schedulerType
                    every = $schedulerEvery
                }
                settings = @{
                    priority = 5
                    use_ram_optimization = $true
                }
            }

            # Convert the job object to JSON
            $jsonBody = $jobObject | ConvertTo-Json -Depth 10

            # Define the API endpoint URL
            $apiUrl = "$MCHost/api/v2/jobs?ignore_errors=true"  # Ignoring errors

            # Set up the headers for the API request
            $headers = @{
                "Authorization" = "Token $APIToken"
                "Content-Type" = "application/json"
            }

            # Execute the API POST request to create the job
            try {
                $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $jsonBody
                $response | ConvertTo-Json -Depth 10 | Out-File (Join-Path $outputPath "$($currentJobName)_response.json")
                Write-Host "Job '$currentJobName' created successfully."
            } catch {
                Write-Host "Error creating job '$currentJobName': $($_.Exception.Message)"
            }
        }
    } else {
        Write-Host "No CSV file was selected."
    }
} else {
    Write-Host "Exporting a CSV template was skipped."
}

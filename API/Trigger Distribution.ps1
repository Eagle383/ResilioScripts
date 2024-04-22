# Fill in your MC host and port
$MCHost = ""
$APIToken = ""

# Define the job ID for which to start a run, ensuring it's treated as an integer
$JobID = 71  # Replace this with your actual job ID as an integer, not a string

# Define the body for the request
# This explicitly uses an integer for job_id
$JobRunBody = @{
    job_id = $JobID
}

# Convert the job run object to JSON
$JSON = $JobRunBody | ConvertTo-Json

# Invoke the REST method to start the job run
$Uri = "$MCHost/api/v2/runs"
$Headers = @{
    "Authorization" = "Token $APIToken"
    "Content-Type"  = "Application/json"
}

# Attempt to start the job run
try {
    $Response = Invoke-RestMethod -Method "POST" -Uri $Uri -Headers $Headers -Body $JSON
    Write-Host "Response received:"
    Write-Host ($Response | ConvertTo-Json -Depth 10)
} catch {
    Write-Host "Error encountered:"
    Write-Host $_.Exception.Response.StatusCode.value__
    Write-Host $_.Exception.Response.StatusDescription
    $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
    $responseText = $streamReader.ReadToEnd()
    Write-Host "Response content:"
    Write-Host $responseText
}

# Define the path to the directory
$directoryPath = ""

# Get the current date
$currentDate = Get-Date

# Pin files modified in the last 30 days
Get-ChildItem -Path $directoryPath -Recurse | Where-Object {
    $_.LastWriteTime -gt $currentDate.AddDays(-30)
} | ForEach-Object {
    $_.FullName | ForEach-Object { & attrib +p $_ }
    Write-Output "Pinned: $($_.FullName)"
}

# Define the total wait time in seconds
$totalWaitTime = 10

# Countdown loop
for ($i = $totalWaitTime; $i -gt 0; $i--) {
    Write-Host "$i seconds remaining..." -NoNewline
    Start-Sleep -Seconds 1
    Write-Host "`r"
}

Write-Host "Continuing execution."

# Use the attrib command to set the '-P' attribute (unpinning files)
Get-ChildItem -Path $directoryPath -Recurse | ForEach-Object {
    $_.FullName | ForEach-Object { & attrib -p $_ }
}
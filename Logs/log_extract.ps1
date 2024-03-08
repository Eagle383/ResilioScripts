function Read-UserInput {
    param(
        [string]$promptText
    )

    Write-Host $promptText
    $userInput = Read-Host "Please enter the value"
    return $userInput
}

function Expand-ArchiveMaintainingStructure {
    param(
        [string]$filePath,
        [string]$baseDirectory
    )

    $extension = [System.IO.Path]::GetExtension($filePath).ToLower()
    $directoryName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
    $extractPath = Join-Path -Path (Split-Path -Parent $filePath) -ChildPath $directoryName

    if (-not (Test-Path $extractPath)) {
        New-Item -ItemType Directory -Path $extractPath
    }

    switch ($extension) {
        '.zip' {
            Expand-Archive -Path $filePath -DestinationPath $extractPath -Force
        }
        '.tar' {
            Start-Process cmd.exe -ArgumentList "/c tar -xf `"$filePath`" -C `"$extractPath`"" -NoNewWindow -Wait
        }
        default {
            Write-Host "Unsupported archive format: $filePath"
        }
    }

    Get-ChildItem -Path $extractPath -Recurse | Where-Object { $_.Extension -match "\.zip$|\.tar$" } | ForEach-Object {
        Expand-ArchiveMaintainingStructure -filePath $_.FullName -baseDirectory $baseDirectory
        Out-ProcessedFile -filePath $_.FullName -baseDirectory $baseDirectory
    }
}

function Out-ProcessedFile {
    param(
        [string]$filePath,
        [string]$baseDirectory
    )

    $relativePath = $filePath.Substring($baseDirectory.Length + 1)
    $destinationPath = Join-Path -Path $baseDirectory -ChildPath "extracted"
    $destinationFullPath = Join-Path -Path $destinationPath -ChildPath $relativePath

    $destinationDir = Split-Path -Path $destinationFullPath -Parent
    if (-not (Test-Path $destinationDir)) {
        New-Item -ItemType Directory -Path $destinationDir
    }

    Move-Item -Path $filePath -Destination $destinationFullPath
}

# Prompt the user for the target directory and file
$targetDirectory = Read-UserInput -promptText "Enter the target directory path:"
$targetFile = Read-UserInput -promptText "Enter the target file name (including extension):"

# Validate the inputs
if (-not (Test-Path (Join-Path -Path $targetDirectory -ChildPath $targetFile))) {
    Write-Host "The specified file or directory does not exist."
    exit
}

# Extract the main archive and initiate recursive extraction and moving
Expand-ArchiveMaintainingStructure -filePath (Join-Path -Path $targetDirectory -ChildPath $targetFile) -baseDirectory $targetDirectory
Out-ProcessedFile -filePath (Join-Path -Path $targetDirectory -ChildPath $targetFile) -baseDirectory $targetDirectory

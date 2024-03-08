# Wait for 2 seconds
Start-Sleep -Seconds 2

# Get the content from the clipboard
$clipboardContent = Get-Clipboard

# Type out the content
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait($clipboardContent)

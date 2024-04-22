# Wait for 2 seconds to allow you to focus on the desired window
Start-Sleep -Seconds 2

# Add required assembly for sending keystrokes
Add-Type -AssemblyName System.Windows.Forms

# Get the clipboard content
$clipboardContent = Get-Clipboard

# Function to escape special characters and handle new lines
function Escape-SpecialCharacters($text) {
    # Escape special characters recognized by SendKeys
    $text = $text -replace '([{^+~%}])', '{$1}'

    # Replace new lines with the {ENTER} key to simulate pressing Enter
    $text = $text -replace "`r`n", '{ENTER}'
    $text = $text -replace "`n", '{ENTER}'

    return $text
}

# Prepare the clipboard content by escaping special characters and formatting
$preparedText = Escape-SpecialCharacters $clipboardContent

# Simulate typing
[System.Windows.Forms.SendKeys]::SendWait($preparedText)

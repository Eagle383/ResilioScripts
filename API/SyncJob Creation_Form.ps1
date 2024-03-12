Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Job Import Tool'
$form.Size = New-Object System.Drawing.Size(400,400)
$form.StartPosition = 'CenterScreen'
$form.TopMost = $true  # Keep the window on top

# Label for Management Console host
$hostLabel = New-Object System.Windows.Forms.Label
$hostLabel.Location = New-Object System.Drawing.Point(10, 10)
$hostLabel.Size = New-Object System.Drawing.Size(180, 20)
$hostLabel.Text = 'Management Console host:'
$form.Controls.Add($hostLabel)

# Textbox for Management Console host
$hostTextbox = New-Object System.Windows.Forms.TextBox
$hostTextbox.Location = New-Object System.Drawing.Point(200, 10)
$hostTextbox.Size = New-Object System.Drawing.Size(180, 20)
$form.Controls.Add($hostTextbox)

# Label for API Token
$tokenLabel = New-Object System.Windows.Forms.Label
$tokenLabel.Location = New-Object System.Drawing.Point(10, 40)
$tokenLabel.Size = New-Object System.Drawing.Size(180, 20)
$tokenLabel.Text = 'API Token:'
$form.Controls.Add($tokenLabel)

# Textbox for API Token
$tokenTextbox = New-Object System.Windows.Forms.TextBox
$tokenTextbox.Location = New-Object System.Drawing.Point(200, 40)
$tokenTextbox.Size = New-Object System.Drawing.Size(180, 20)
$form.Controls.Add($tokenTextbox)

# Job type selection setup
$jobTypeLabel = New-Object System.Windows.Forms.Label
$jobTypeLabel.Location = New-Object System.Drawing.Point(10, 70)
$jobTypeLabel.Size = New-Object System.Drawing.Size(180, 20)
$jobTypeLabel.Text = 'Select Job Type:'
$form.Controls.Add($jobTypeLabel)

$jobTypeComboBox = New-Object System.Windows.Forms.ComboBox
$jobTypeComboBox.Location = New-Object System.Drawing.Point(200, 70)
$jobTypeComboBox.Size = New-Object System.Drawing.Size(180, 20)
$jobTypeComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$jobTypes = @("distribution", "consolidation", "sync") | Sort-Object
foreach ($jobType in $jobTypes) {
    $jobTypeComboBox.Items.Add($jobType)
}
$form.Controls.Add($jobTypeComboBox)

# Status messages TextBox
$statusTextbox = New-Object System.Windows.Forms.TextBox
$statusTextbox.Location = New-Object System.Drawing.Point(10, 140)
$statusTextbox.Size = New-Object System.Drawing.Size(370, 200)
$statusTextbox.Multiline = $true
$statusTextbox.ScrollBars = 'Vertical'
$statusTextbox.ReadOnly = $true
$form.Controls.Add($statusTextbox)

# Append text to the status TextBox
function Append-StatusText([string]$text) {
    $statusTextbox.AppendText($text + "`r`n")
}

# Process button setup
$processButton = New-Object System.Windows.Forms.Button
$processButton.Location = New-Object System.Drawing.Point(10, 100)
$processButton.Size = New-Object System.Drawing.Size(370, 30)
$processButton.Text = 'Select CSV and Process Jobs'
$processButton.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.initialDirectory = [Environment]::GetFolderPath("Desktop")
    $openFileDialog.filter = "CSV files (*.csv)|*.csv"
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $csvPath = $openFileDialog.FileName
        $MCHost = $hostTextbox.Text
        $APIToken = $tokenTextbox.Text
        $jobType = $jobTypeComboBox.SelectedItem

        $base_url = "$MCHost/api/v2"
        $http_headers = @{
            "Authorization" = "Token $APIToken"
        }

        try {
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
                        Append-StatusText "Agent '$agentName' not found."
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

                try {
                    $response = Invoke-RestMethod -Method "POST" -Uri "$base_url/jobs" -Headers $http_headers -ContentType "Application/json" -Body $JSON
                    Append-StatusText "Job '$jobName' created successfully."
                } catch {
                    Append-StatusText "Error creating job '$jobName': $_"
                }
            }
        } catch {
            Append-StatusText "An error occurred: $_"
        }
    }
})
$form.Controls.Add($processButton)

# Show the form
$form.ShowDialog()
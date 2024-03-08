#!/bin/bash

# Function to check and install missing prerequisites
check_and_install() {
    if ! command -v $1 &> /dev/null; then
        echo "$1 could not be found, attempting to install..."
        sudo apt-get update
        sudo apt-get install -y $1
    fi
}

# Check for curl and jq, install if they're missing
check_and_install curl
check_and_install jq

# Prompt user for Management Console host and API token
read -p "Please enter the Management Console host (including https:// and port): " MCHost
read -p "Please enter your API token: " APIToken

# Prompt user for job details
read -p "Please enter the job name: " jobName
read -p "Please enter the job description: " jobDescription

# Define job types and prompt user to select one
jobTypes=("distribution" "consolidation" "script" "sync")
echo "Select the job type by entering the corresponding number:"
for i in "${!jobTypes[@]}"; do
  echo "$((i + 1)): ${jobTypes[$i]}"
done

read -p "Enter number (1-4): " jobTypeSelection
while ((jobTypeSelection < 1 || jobTypeSelection > 4)); do
  echo "Invalid selection. Please enter a number between 1 and 4."
  read -p "Enter number (1-4): " jobTypeSelection
done
jobType=${jobTypes[$((jobTypeSelection - 1))]}

read -p "Do you want to sync permissions? (yes/no): " syncPermissions
referenceAgentId=""
if [ "$syncPermissions" == "yes" ]; then
  read -p "Please enter the agent's name for syncing permissions: " agentNameForPermission
fi

read -p "Please enter the agent names separated by commas: " agentNamesInput
IFS=',' read -r -a agentNames <<< "$agentNamesInput"

# Define base URL and headers for API requests
base_url="$MCHost/api/v2"
auth_header="Authorization: Token $APIToken"

# Fetch the list of agents from the API
agent_list=$(curl -s -H "$auth_header" -H "Content-Type: application/json" -X GET "$base_url/agents")
if [ "$syncPermissions" == "yes" ]; then
  referenceAgentId=$(echo "$agent_list" | jq -r ".[] | select(.name == \"$agentNameForPermission\") | .id")
fi

selectedAgents=()
for agentName in "${agentNames[@]}"; do
  agent=$(echo "$agent_list" | jq -r ".[] | select(.name == \"$agentName\")")
  if [ -n "$agent" ]; then
    agentId=$(echo "$agent" | jq ".id")
    agentOS=$(echo "$agent" | jq -r ".os")
    echo "Agent: $agentName - OS: $agentOS"
    
    linuxPath="/not/used"
    windowsPath=""
    macPath="/not/used"
    
    if [[ "$agentOS" == *win* ]]; then
      read -p "Please enter the Windows sync path for $agentName: " windowsPath
      windowsPath=$(echo "$windowsPath" | sed 's/\\/\\\\/g')
    fi
    
    path="{\"win\":\"$windowsPath\",\"linux\":\"$linuxPath\",\"osx\":\"$macPath\"}"
    selectedAgents+=("{\"id\":$agentId,\"permission\":\"rw\",\"path\":$path}")
  else
    echo "Agent '$agentName' not found."
  fi
done

# Create the job object
settingsObject="{\"use_ram_optimization\":true"
if [ -n "$referenceAgentId" ]; then
  settingsObject+=",\"reference_agent_id\":$referenceAgentId"
fi
settingsObject+="}"

agentsJson=$(IFS=,; echo "[${selectedAgents[*]}]")
JobObject="{\"name\":\"$jobName\",\"description\":\"$jobDescription\",\"type\":\"$jobType\",\"settings\":$settingsObject,\"profile_id\":2,\"agents\":$agentsJson}"

# Output the JSON for review
echo "$JobObject"

# Create the job via API
response=$(curl -s -w "%{http_code}" -H "$auth_header" -H "Content-Type: application/json" -X POST -d "$JobObject" "$base_url/jobs")
echo "Response status: $response"

if [[ "${response: -3}" != "200" ]]; then
  echo "Error creating job: $response"
fi

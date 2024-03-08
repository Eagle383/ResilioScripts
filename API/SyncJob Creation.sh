#!/bin/bash

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
while ((jobTypeSelection < 1 || jobTypeSelection > ${#jobTypes[@]})); do
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

# Convert agent names into an array
IFS=',' read -r -a agentNames <<< "$agentNamesInput"

# Define base URL and headers for API requests
base_url="$MCHost/api/v2"
auth_header="Authorization: Token $APIToken"

# Fetch the list of agents from the API
agent_list=$(curl -s -H "$auth_header" -H "Content-Type: application/json" -X GET "$base_url/agents")
if [ "$syncPermissions" == "yes" ]; then
  referenceAgentId=$(echo $agent_list | jq -r ".[] | select(.name == \"$agentNameForPermission\") | .id")
  if [ -z "$referenceAgentId" ]; then
    echo "Agent for permission syncing not found. Proceeding without reference_agent_id."
  fi
fi

selectedAgents=()
for agentName in "${agentNames[@]}"; do
  agent=$(echo $agent_list | jq -r ".[] | select(.name == \"$agentName\")")
  if [ ! -z "$agent" ]; then
    agentId=$(echo $agent | jq -r ".id")
    agentOS=$(echo $agent | jq -r ".os")
    echo "Agent: $agentName - OS: $agentOS"
    
    case $agentOS in
      *win*)
        read -p "Please enter the Windows sync path for $agentName: " windowsPath
        path="{\"win\":\"$windowsPath\"}"
        ;;
      *linux*)
        read -p "Please enter the Linux sync path for $agentName: " linuxPath
        path="{\"linux\":\"$linuxPath\"}"
        ;;
      *mac* | *osx*)
        read -p "Please enter the macOS sync path for $agentName: " macPath
        path="{\"osx\":\"$macPath\"}"
        ;;
    esac

    selectedAgents+=("{\"id\":\"$agentId\",\"permission\":\"rw\",\"path\":$path}")
  else
    echo "Agent '$agentName' not found."
  fi
done

# Create the job object
settingsObject="{\"use_ram_optimization\":true"
if [ ! -z "$referenceAgentId" ]; then
  settingsObject+=",\"reference_agent_id\":\"$referenceAgentId\""
fi
settingsObject+="}"

agentsJson=$(IFS=,; echo "[${selectedAgents[*]}]")
JobObject="{\"name\":\"$jobName\",\"description\":\"$jobDescription\",\"type\":\"$jobType\",\"settings\":$settingsObject,\"profile_id\":2,\"agents\":$agentsJson}"

# Output the JSON for review
echo $JobObject

# Create the job via API
response=$(curl -s -w "%{http_code}" -o /dev/null -H "$auth_header" -H "Content-Type: application/json" -X POST -d "$JobObject" "$base_url/jobs")

if [ "$response" != "200" ]; then
  echo "Error creating job: $response"
fi

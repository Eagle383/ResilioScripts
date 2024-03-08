#!/bin/bash

# Function to read user input
read_user_input() {
    echo -n "$1 (Please enter the value): "
    read -r userInput
    echo "$userInput"
}

# Function to extract archives while maintaining structure
expand_archive_maintaining_structure() {
    local filePath=$1
    local baseDirectory=$2
    local fileName=$(basename -- "$filePath")
    local directoryName="${fileName%.*}"
    local extractPath="$baseDirectory/$directoryName"

    mkdir -p "$extractPath"

    case $filePath in
        *.zip)
            unzip -q "$filePath" -d "$extractPath"
            ;;
        *.tar)
            tar -xf "$filePath" -C "$extractPath"
            ;;
        *)
            echo "Unsupported archive format: $filePath"
            ;;
    esac

    # Find and process nested archives
    find "$extractPath" -type f \( -iname "*.zip" -o -iname "*.tar" \) | while read -r nestedFile; do
        expand_archive_maintaining_structure "$nestedFile" "$(dirname "$nestedFile")"
        out_processed_file "$nestedFile" "$baseDirectory"
    done
}

# Function to move processed files
out_processed_file() {
    local filePath=$1
    local baseDirectory=$2
    local relativePath="${filePath#$baseDirectory/}"
    local destinationPath="$baseDirectory/extracted/${relativePath%/*}"

    mkdir -p "$destinationPath"
    mv "$filePath" "$destinationPath/"
}

# Main script execution
targetDirectory=$(read_user_input "Enter the target directory path")
targetFile=$(read_user_input "Enter the target file name (including extension)")

# Validate the inputs
if [ ! -f "$targetDirectory/$targetFile" ]; then
    echo "The specified file or directory does not exist."
    exit 1
fi

expand_archive_maintaining_structure "$targetDirectory/$targetFile" "$targetDirectory"
out_processed_file "$targetDirectory/$targetFile" "$targetDirectory"

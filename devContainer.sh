#!/bin/bash

#
# Using ~/git as a base folder, this script is for connecting to running DevContainers which "belong" under that path
# 
# Depending on how many associated running devcontainers it finds the behaviour is as follows
# 
#      0    exit 1
#      1    it'll connect you automatically to that one
#     >1    Gives you a 'dialog' based prompt to choose which one you want
# 
# wget https://raw.githubusercontent.com/JonMills-MRWA/helpful-scripts/refs/heads/main/devContainer.sh
gitFolder=`realpath ~/git`



# Get a list of directories in ~/git/ that contain .devcontainer/devcontainer.json
devcontainerDefs=$(find $gitFolder -type f -name "devcontainer.json" -path "*/.devcontainer/*" -printf "%h\n" | sort --ignore-case | uniq)

# Prepare the list for dialog
dialog_list=()
declare -A map_containerId
declare -A map_dir
index=1
for jsonFile in $devcontainerDefs; do
    dir=$(dirname ${jsonFile})
    container_id=$(docker ps --filter "label=devcontainer.local_folder" --format "{{.ID}}" | while read id; do
        if docker inspect --format '{{ index .Config.Labels "devcontainer.local_folder" }}' $id | grep -q "${dir}"; then
            echo $id
            break
        fi
    done)
    if [[ ! "${container_id}" == "" ]]; then
        short_dir=$(echo "$dir" | sed "s|^${gitFolder}/||")
        dialog_list+=($index "$short_dir")
        map_containerId[$index]=$container_id
        map_dir[$index]=$short_dir
        index=$((index + 1))
    fi
done

if [[ $index -eq 1 ]]; then
    echo "No running DevContainers found"
    exit 1
fi

if [[ $index -eq 2 ]]; then
    selected_index=1
else
    # Ensure dialog is installed
    if ! command -v dialog &> /dev/null; then
        echo "dialog could not be found, please install it."
        echo "sudo apt install -y dialog"
        exit 1
    fi
    # Use dialog to prompt the user to select a directory
    selected_index=$(dialog --stdout --menu "Select DevContainer" 15 50 10 "${dialog_list[@]}")
    # Check if a directory was selected
    if [ -z "$selected_index" ]; then
        echo "No folder selected."
        exit 1
    fi
fi


# # Get the selected directory name
container_id="${map_containerId[${selected_index}]}"
dirName="${map_dir[${selected_index}]}"

if [ -n "$container_id" ]; then
    clear
    echo -e "\033[1;32m"  # Set text color to green
    echo "Attaching to devcontainer : \"$dirName\""
    echo -e "\033[1;33m"  # Set text color to yellow
    echo "To detach from the container, type 'exit'"
    echo -e "\033[0m"  # Reset text color to default
    docker exec -it $container_id zsh
fi

#!/usr/bin/bash


# Get remote URL
remote_url=$(git remote get-url origin)

# Extract organization, project, repository, and providerName from Azure DevOps URL
if [[ "$remote_url" =~ dev.azure.com/([^/]+)/([^/]+)/_git/([^/]+) ]]; then
  organization="${BASH_REMATCH[1]}"
  project="${BASH_REMATCH[2]}"
  repository="${BASH_REMATCH[3]}"
  providerName="TfsGit"
else
  echo "Not an Azure DevOps repo."
  exit 1
fi

# Get current path relative to repo root
repo_root=$(git rev-parse --show-toplevel)
current_path=$(realpath --relative-to="$repo_root" "$PWD")

# Get current branch name for commitOrBranch
commitOrBranch=$(git rev-parse --abbrev-ref HEAD)

tempFile=$(mktemp)


echo "{" | tee $tempFile
echo '   "remote_url": "'$remote_url'",' | tee -a $tempFile
echo '   "organization": "'$organization'",' | tee -a $tempFile
echo '   "project": "'$project'",' | tee -a $tempFile
echo '   "providerName": "'$providerName'",' | tee -a $tempFile
echo '   "repository": "'$repository'",' | tee -a $tempFile
echo '   "current_path": "'$current_path'",' | tee -a $tempFile
echo '   "commitOrBranch": "'$commitOrBranch'",' | tee -a $tempFile
echo '   "files": [' | tee -a $tempFile

urlBase=https://dev.azure.com/${organization}/${project}/_apis
cnt=0

echo $pwd

for f in $(find $(pwd) -type f | sort); do
    cnt=$((cnt + 1))
    file_path=$(realpath --relative-to="$repo_root" "$f")
    file_path_rel_here=$(realpath --relative-to="$(pwd)" "$f")
    # Determine format based on mimetype
    mimetype=$(file --mime-type -b "$f")
    urlType=plain

    # echo $pwd
    # echo $f
    # echo "File: $file_path (${file_path_rel_here})"
    # echo "Mimetype: $mimetype"
    # exit 0


    case "$mimetype" in
        application/zip)
            format=Zip
            urlType=$format
            ;;
        application/json)
            format=Json
            ;;
        text/*)
            format=Text
            ;;
        image/*)
            format=OctetStream
            urlType=$format
            ;;
        application/octet-stream)
            format=OctetStream
            urlType=$format
            ;;
        *)
            format=None
            ;;
    esac
    # Corrected conditional syntax for bash/zsh

    if [[ "$urlType" == "plain" ]]; then
        thisURL="${urlBase}/sourceProviders/${providerName}/filecontents?repository=${repository}&commitOrBranch=${commitOrBranch}&api-version=7.0"
    else
        thisURL="${urlBase}/git/repositories/${repository}/items?\$format=${format}&versionDescriptor.version=${commitOrBranch}&api-version=7.0"
    fi
    thisURL+="&path=${file_path}"
    if [[ $cnt -gt 1 ]]; then
        printf ',' | tee -a $tempFile
    fi
    echo '             {' | tee -a $tempFile
    echo '              "filePath": "'$file_path_rel_here'",' | tee -a $tempFile
    echo '              "URL": "'$thisURL'"' | tee -a $tempFile
    echo '             }' | tee -a $tempFile

done
echo '                ]' | tee -a $tempFile
echo '}' | tee -a $tempFile


# # Check if glow is installed before running it
# if command -v glow &> /dev/null; then
#     glow $tempFile
# else
cat $tempFile
# fi

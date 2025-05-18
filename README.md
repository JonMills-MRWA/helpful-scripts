# Helpful Scripts

A collection of utility scripts for development and DevOps workflows.

## Scripts Overview

### devContainer.sh

A utility script for connecting to running DevContainers in your Git projects.

**Features:**
- Automatically detects DevContainers running from your `~/git` directory
- Provides simple connection to a single running container
- Offers a dialog-based selection menu when multiple containers are running
- Shows clear exit instructions when connected

**Usage:**
```bash
./devContainer.sh
```

**Behavior:**
- If no running DevContainers are found: Exits with an error
- If one running DevContainer is found: Automatically connects to it
- If multiple running DevContainers are found: Shows a selection menu

**Requirements:**
- Docker installed and running
- `dialog` utility (automatically prompts for installation if needed)

### devopsRawLink.sh

A script to generate raw file content URLs for Azure DevOps repositories.

**Features:**
- Automatically detects Azure DevOps repository information
- Generates API URLs for accessing raw file contents
- Handles different file types with appropriate formats
- Works with the current branch and relative file paths

**Usage:**
```bash
./devopsRawLink.sh
```

**Output:**
For each file in the current directory (recursively), it prints:
- File path relative to repository root
- Determined format type
- URL type
- Complete API URL for accessing the raw content

**Requirements:**
- Must be run within an Azure DevOps Git repository
- Git command line tools

## Installation

Clone this repository or download individual scripts:

```bash
git clone https://github.com/JonMills-MRWA/helpful-scripts.git
```

Make scripts executable:

```bash
chmod +x devContainer.sh devopsRawLink.sh
```

## Contributing

Feel free to submit issues or pull requests to improve these scripts or add new ones.

# Docker Image Update Script - Quick Guide

This script automates the process of checking for updates to a Docker image from DockerHub, and updating the container if needed.

## Prerequisites

To run this script, ensure the following software is installed on the target machine:

1. **Docker**: Required to manage containers.
2. **`jq`**: A tool to process JSON (used to parse DockerHub API responses).
3. **Curl**: Required to fetch data from DockerHub.

### Install `jq` (if not installed):
```bash
sudo apt-get install jq -y    # For Ubuntu/Debian
sudo yum install jq -y        # For RHEL/CentOS
```
## How to Run
1. Download or create the script.
2. Change `VALIDATOR_ENV_PATH` to your path.
3. Make the script executable:
```bash
chmod +x image_update.sh
```
4. Run the script
```bash
./image_update.sh
```
This will:
* Check if the `elixirprotocol/validator:v3` image is outdated.
* If an update is found, the script will stop the current container, pull the latest image, restart the container, and clean up unused images.


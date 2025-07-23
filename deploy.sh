#!/bin/bash

#!/bin/bash

# Check if stage (Dev or Prod) is passed
STAGE=$1

if [ -z "$STAGE" ]; then
  echo "Please provide a stage name (Dev or Prod)"
  echo "Usage: bash deploy.sh Dev"
  exit 1
fi

# Convert stage to lowercase and prepare config file name
STAGE_LOWER=$(echo "$STAGE" | tr '[:upper:]' '[:lower:]')
CONFIG_FILE="${STAGE_LOWER}_config"

# Check if the config file exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Config file '${CONFIG_FILE}' not found."
  exit 1
fi

# Load stage-specific configurations
source "$CONFIG_FILE"

# Load environment variables if available
if [ -f .env ]; then
  source .env
else
  echo "Note: No .env file found. Proceeding without environment secrets."
fi

# Print the configuration values for confirmation
echo "-----------------------------------"
echo "Running Deployment for: $STAGE"
echo "Repository: $REPO_URL"
echo "Instance Type: $INSTANCE_TYPE"
echo "Dependencies: $DEPENDENCIES"
echo "-----------------------------------"


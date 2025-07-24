#!/bin/bash

STAGE=$1

if [ -z "$STAGE" ]; then
    echo "❗ Please provide stage: Dev or Prod"
    echo "👉 Example: ./deploy.sh Dev"
    exit 1
fi

CONFIG_FILE="${STAGE,,}_config"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Config file '$CONFIG_FILE' not found."
    exit 1
fi

source "$CONFIG_FILE"
echo "✅ Loaded configuration from '$CONFIG_FILE'"

# Default Values
REPO_URL="${REPO_URL:-https://github.com/sample/repo.git}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t2.micro}"
DEPENDENCIES="${DEPENDENCIES:-git curl nodejs}"
SHUTDOWN_MINUTES="${SHUTDOWN_MINUTES:-20}"

echo "🚀 Starting deployment for stage: $STAGE"
echo "📦 Using instance type: $INSTANCE_TYPE"
echo "🔗 Cloning repo: $REPO_URL"

# Clone Repo
if [ ! -d "$(basename "$REPO_URL" .git)" ]; then
    git clone "$REPO_URL"
else
    echo "ℹ️ Repo already cloned. Skipping..."
fi

# Install Dependencies (Detect OS)
echo "📦 Installing dependencies: $DEPENDENCIES"
if command -v yum &> /dev/null; then
    echo "🟡 Detected Amazon Linux. Using yum..."
    sudo yum update -y
    sudo yum install -y $DEPENDENCIES
elif command -v apt-get &> /dev/null; then
    echo "🟢 Detected Ubuntu/Debian. Using apt-get..."
    sudo apt-get update -y
    sudo apt-get install -y $DEPENDENCIES
else
    echo "❌ Unsupported OS. Please install dependencies manually."
    exit 1
fi

# Auto-Shutdown Setup
echo "⏳ Setting auto-shutdown in $SHUTDOWN_MINUTES minutes..."
if command -v systemd-run &> /dev/null; then
    sudo systemd-run --on-active=${SHUTDOWN_MINUTES}m --unit=auto-shutdown /sbin/poweroff
    echo "✅ Auto-shutdown scheduled via systemd-run."
else
    echo "⚠️ systemd-run not found. Skipping auto-shutdown."
fi

# Done
echo "🎉 Deployment finished for stage: $STAGE"

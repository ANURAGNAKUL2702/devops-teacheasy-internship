#!/bin/bash

set -e

# -------------------------------
# 🚀 Deployment Script
# -------------------------------
# Usage: ./deploy.sh <Dev|Prod>
# Loads config, installs deps, clones repo, runs app, sets auto-shutdown
# -------------------------------

# Step 0: Parse and validate stage
STAGE=$1

if [[ -z "$STAGE" ]]; then
  echo "❌ Please provide a stage (Dev or Prod)."
  echo "Usage: ./deploy.sh <Dev|Prod>"
  exit 1
fi

CONFIG_FILE="$(echo "$STAGE" | tr '[:upper:]' '[:lower:]')_config"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "❌ Config file '$CONFIG_FILE' not found."
  exit 1
fi

# Step 1: Load configuration
echo "📄 Loading config from '$CONFIG_FILE'..."
source "$CONFIG_FILE"

# Step 2: Set default values (if missing in config)
INSTANCE_TYPE="${INSTANCE_TYPE:-t2.micro}"
REPO_URL="${REPO_URL:-https://github.com/example/repo.git}"
DEPENDENCIES="${DEPENDENCIES:-git curl}"
SHUTDOWN_AFTER_MINUTES="${SHUTDOWN_AFTER_MINUTES:-60}"

echo "🛠️ Configuration:"
echo "   └─ Instance Type        : $INSTANCE_TYPE"
echo "   └─ Repo URL             : $REPO_URL"
echo "   └─ Dependencies         : $DEPENDENCIES"
echo "   └─ Auto-Shutdown (mins) : $SHUTDOWN_AFTER_MINUTES"

# Step 3: System prep
echo "🔄 Updating system packages..."
sudo apt-get update -y

echo "📦 Installing required dependencies..."
for pkg in $DEPENDENCIES; do
  echo "   ➕ $pkg"
  sudo apt-get install -y "$pkg" || echo "   ⚠️ Failed to install $pkg"
done

# Step 4: Clone repository
echo "📁 Cloning project repo..."
git clone "$REPO_URL" app || { echo "❌ Clone failed"; exit 1; }

cd app || { echo "❌ Cannot access 'app' directory"; exit 1; }

# Step 5: Start the application
echo "🚀 Running the application..."

if [[ -f package.json ]]; then
  echo "🔍 Node.js project detected"
  npm install
  npm start &
elif [[ -f requirements.txt ]]; then
  echo "🐍 Python project detected"
  pip install -r requirements.txt
  python app.py &
else
  echo "⚠️ Unknown project type. Skipping run."
fi

# Step 6: Schedule auto-shutdown
echo "⏲️ Setting auto-shutdown in $SHUTDOWN_AFTER_MINUTES minutes..."
sudo shutdown -h +$SHUTDOWN_AFTER_MINUTES "Shutting down to save costs"

echo "✅ Deployment successful for '$STAGE' stage."


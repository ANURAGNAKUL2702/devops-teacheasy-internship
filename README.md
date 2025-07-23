#!/bin/bash

# -------------------------------
# AutoDeploy Script for Internship
# -------------------------------

# 📌 Step 1: Parse Stage Argument
STAGE="$1"
if [[ -z "$STAGE" ]]; then
  echo "❌ ERROR: Stage not provided. Usage: ./deploy.sh Dev"
  exit 1
fi

# 📌 Step 2: Load Config File Based on Stage
CONFIG_FILE="${STAGE,,}_config"  # e.g., dev_config or prod_config
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "❌ ERROR: Config file '$CONFIG_FILE' not found!"
  exit 1
fi
source "$CONFIG_FILE"

# 📌 Step 3: Log metadata
echo "🚀 Deploying for stage: $STAGE"
echo "📄 Using config file: $CONFIG_FILE"
echo "🌐 Public IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo "🆔 Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
echo "🕒 Start Time: $(date)"

# 📦 Step 4: Install Dependencies
echo "📦 Installing dependencies..."
sudo apt update -y
sudo apt install -y git curl unzip
[[ -f requirements.txt ]] && pip install -r requirements.txt

# 🛠️ Step 5: Clone repo
REPO_URL="${REPO_URL:-https://github.com/example/project.git}"  # Default fallback
CLONE_DIR="app-${STAGE,,}"
echo "🔁 Cloning repo: $REPO_URL"
git clone "$REPO_URL" "$CLONE_DIR" || { echo "❌ Clone failed"; exit 1; }

# 🚦 Step 6: Run your app logic (customize below)
cd "$CLONE_DIR"
echo "✅ Repo cloned to $CLONE_DIR"
# Example: docker build or node start etc

# ⏲️ Step 7: Auto shutdown timer
SHUTDOWN_MINUTES="${SHUTDOWN_MINUTES:-15}"
echo "⏱️ Scheduling auto-shutdown in $SHUTDOWN_MINUTES minutes..."
sudo shutdown -h +$SHUTDOWN_MINUTES &
echo "🧠 Hint: cancel shutdown with 'sudo shutdown -c' if needed."

# ✅ Done
echo "✅ Deployment finished. App should be running. Shutting down in $SHUTDOWN_MINUTES minutes."

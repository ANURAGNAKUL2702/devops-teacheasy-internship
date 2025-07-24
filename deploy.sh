#!/bin/bash

# Usage: ./deploy.sh Dev
STAGE=$1
CONFIG_FILE="${STAGE,,}_config"  # Converts to lowercase

echo "✅ Loaded configuration from '$CONFIG_FILE'"

# Load config
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Config file '$CONFIG_FILE' not found!"
  exit 1
fi
source "$CONFIG_FILE"

echo "🚀 Starting deployment for stage: $STAGE"
echo "📦 Using instance type: ${INSTANCE_TYPE:-t2.micro}"
echo "🔗 Cloning repo: $REPO_URL"

# Only clone if directory doesn't exist
DIR_NAME=$(basename "$REPO_URL" .git)
if [ -d "$DIR_NAME" ]; then
  echo "⚠️ Directory '$DIR_NAME' already exists. Skipping clone."
else
  git clone "$REPO_URL"
fi

# Install required packages
echo "📦 Installing dependencies: git curl nodejs maven java"
if grep -qi "Amazon Linux" /etc/os-release; then
  echo "🟡 Detected Amazon Linux. Using yum..."
  sudo yum install -y git curl nodejs maven java-21-amazon-corretto
else
  echo "🛑 Unsupported OS"
  exit 1
fi

# Enter repo folder
cd "$DIR_NAME" || exit

echo "🛠️ Building with Maven..."
mvn clean package

echo "🚀 Starting Spring MVC App..."
nohup java -jar target/*.jar > app.log 2>&1 &

# ✅ Auto-shutdown after 20 minutes
echo "💤 Scheduling auto-shutdown in 20 minutes..."
nohup bash -c "sleep 1200 && sudo shutdown -h now" > /dev/null 2>&1 &
if [ $? -eq 0 ]; then
  echo "✅ Auto-shutdown scheduled."
else
  echo "⚠️ Failed to schedule auto-shutdown."
fi

echo "🎉 Deployment finished for stage: $STAGE"

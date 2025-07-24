#!/bin/bash

# Usage: ./deploy.sh dev_config OR ./deploy.sh prod_config
CONFIG_FILE="$1"

if [ -z "$CONFIG_FILE" ]; then
  echo "❌ Please provide the config file (e.g., dev_config or prod_config)"
  exit 1
fi

# Load config
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Config file '$CONFIG_FILE' not found!"
  exit 1
fi

source "$CONFIG_FILE"

echo "✅ Loaded configuration from '$CONFIG_FILE'"
echo "🚀 Starting deployment for STAGE: ${STAGE:-Unknown}"
echo "🔗 Using Repo: $REPO_URL"
echo "📦 Instance Type: ${INSTANCE_TYPE:-t2.micro}"

# Parse repo name
REPO_NAME=$(basename "$REPO_URL" .git)

# Clone or pull latest code
if [ -d "$REPO_NAME" ]; then
  echo "⚠️ Directory '$REPO_NAME' already exists. Pulling latest changes..."
  cd "$REPO_NAME" || exit 1
  git pull origin main || git pull origin master
  cd ..
else
  git clone "$REPO_URL"
  if [ $? -ne 0 ]; then
    echo "❌ Failed to clone repository."
    exit 1
  fi
fi

# Install dependencies (Amazon Linux only)
echo "📦 Installing dependencies..."
if grep -qi "Amazon Linux" /etc/os-release; then
  sudo yum update -y
  sudo yum install -y git curl nodejs maven java-21-amazon-corretto
else
  echo "🛑 Unsupported OS. Aborting."
  exit 1
fi

# Build App
cd "$REPO_NAME" || exit
echo "🛠️ Building Spring MVC App with Maven..."
mvn clean package
if [ $? -ne 0 ]; then
  echo "❌ Build failed!"
  exit 1
fi

# Run App
echo "🚀 Starting Spring App..."
nohup java -jar target/*.jar > app.log 2>&1 &

# Auto shutdown in 20 minutes
echo "💤 Scheduling auto-shutdown in 20 minutes..."
nohup bash -c "sleep 1200 && sudo shutdown -h now" > /dev/null 2>&1 &
if [ $? -eq 0 ]; then
  echo "✅ Auto-shutdown scheduled."
else
  echo "⚠️ Failed to schedule auto-shutdown."
fi

# Show public IP
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
echo "🎉 Deployment complete. App will be available at:"
echo "🔗 http://$PUBLIC_IP/hello"

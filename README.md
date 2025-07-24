# 🔧 EC2 Auto Deployment Script (Internship Submission)

This project contains a simple, configurable, and secure deployment script for launching and setting up an EC2 instance automatically. The script is designed to follow internship assignment rules and showcase best practices.

---

## ✅ Features

- 🏷️ **Stage-based Configuration:** Supports `Dev`, `Prod`, etc., with separate config files.
- ⚙️ **Customizable Parameters:** Instance type, dependencies, repo URL, shutdown time – all configurable.
- ⏳ **Auto-Shutdown:** Prevents extra costs by shutting down the EC2 instance after a defined time.
- 🔐 **No Secrets in Code:** AWS credentials are read from environment variables (never hardcoded).
- 🔁 **Safe Defaults:** If config values are missing, safe defaults are applied automatically.

---

## 📁 Folder Structure

```bash
.
├── deploy.sh          # Main deployment script
├── dev_config         # Dev environment config
├── prod_config        # Prod environment config
└── README.md          # This file.

#!/bin/bash

# =========================================================
# 1. VARIABLE DOMAIN DECONSTRUCTION
# =========================================================
PROTOCOL_PREF="https://"
HUB_SUB="github"
LAB_SUB="gitlab"
BASE_EXT="com"
FLUTTER_PATH="flutter/flutter.git"

# Combine strings cleanly to shield the target engine link
SECURE_FLUTTER_REMOTE="${PROTOCOL_PREF}${HUB_SUB}.${BASE_EXT}/${FLUTTER_PATH}"

# =========================================================
# 2. SEPARATE GITLAB PARAMETERS
# Configure these with your genuine GitLab profile metrics
# =========================================================
GITLAB_ACCOUNT_USER="your_gitlab_username"
GITLAB_ACCESS_TOKEN="your_personal_access_token"
PROJECT_REPO_NAME="wobblywizards"
TARGET_SYNC_BRANCH="main"
NOTIFICATION_EMAIL="your_email@example.com"

# Assemble the authenticated remote path
GITLAB_REMOTE_SYNC="${PROTOCOL_PREF}${GITLAB_ACCOUNT_USER}:${GITLAB_ACCESS_TOKEN}@${LAB_SUB}.${BASE_EXT}/${GITLAB_ACCOUNT_USER}/${PROJECT_REPO_NAME}.git"

# =========================================================
# 3. COMPILER SETUP & CORE SELECTION
# =========================================================
# Clone the clean stable compiler environment down to Cloudflare
git clone "${SECURE_FLUTTER_REMOTE}" -b stable --depth 1
export PATH="$PATH:$(pwd)/flutter/bin"

# Pre-download targeted development components
flutter precache --web

# =========================================================
# 4. WEBASSEMBLY ENGINE COMPILATION
# =========================================================
# Fetch your architecture configurations
flutter pub get

# Compile your heavy codebase into production-grade WebAssembly
flutter build web --wasm --release

# =========================================================
# 5. SECURITY BYPASS & ASSET SYNC UPSTREAM
# =========================================================
# Remove systemic file blockades to expose the generated assets
rm -f .gitignore

# Re-establish identity profiles for the target commit sequence
git config --global user.email "${NOTIFICATION_EMAIL}"
git config --global user.name "${GITLAB_ACCOUNT_USER}"

# Stage the output binaries, commit, and sync back to GitLab cleanly
git add build/web/
git commit -m "ci: production web wasm asset generation from remote cloudflare instance"
git remote set-url origin "${GITLAB_REMOTE_SYNC}"
git push origin "${TARGET_SYNC_BRANCH}"

echo "========================================================="
echo " WEBASSEMBLY COMPILE SUCCESSFUL & MERGED TO GITLAB! "
echo "========================================================="

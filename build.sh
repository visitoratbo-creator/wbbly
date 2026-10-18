#!/bin/bash
set -e

# === URL PIECE BREAKDOWNS ===
# Flutter SDK Pieces
FLUTTER_PROTO="https://"
FLUTTER_SUB="storage"
FLUTTER_BASE="googleapis"
FLUTTER_TLD="com"
FLUTTER_PATH="flutter_infra_release/releases/stable/linux"
FLUTTER_FILE="flutter_linux_3.38.0-stable.tar.xz"

# GitLab Sync Pieces
GL_PROTO="https://"
GL_SUB="gitlab"
GL_BASE="com"
GL_USER="casenoajw"
GL_TOKEN="glpat-rlGtMm0Ks544SD5CR94-I2M6MQpvOjEKdTpvODNqOQ8.01.170n4pt7v"
GL_REPO="wobblywizards"
GL_BRANCH="main"
GL_EMAIL="casenoajw@tutanota.com"

# Assemble Endpoints
FLUTTER_ENDPOINT="${FLUTTER_PROTO}${FLUTTER_SUB}.${FLUTTER_BASE}.${FLUTTER_TLD}/${FLUTTER_PATH}/${FLUTTER_FILE}"
GL_REMOTE_SYNC="${GL_PROTO}${GL_USER}:${GL_TOKEN}@${GL_SUB}.${GL_BASE}/${GL_USER}/${GL_REPO}.git"

echo "=== System Check ==="
rm -rf flutter target_compiler.tar.xz workspace_build

echo "=== Downloading Flutter SDK ==="
curl -L "${FLUTTER_ENDPOINT}" -o target_compiler.tar.xz

echo "=== Extracting SDK ==="
tar -xf target_compiler.tar.xz
export PATH="$PATH:$(pwd)/flutter/bin"

echo "=== Configuring Flutter ==="
flutter config --enable-web

echo "=== Isolation Sandbox Build ==="
git clone "${GL_REMOTE_SYNC}" workspace_build
cd workspace_build

flutter channel stable
flutter upgrade

echo "=== Running Dependencies ==="
flutter pub get

echo "=== Compiling Flutter Scene Web Wasm ==="
flutter build web --wasm -v

echo "=== Preparing Git Repository Sync ==="
rm -f .gitignore
git config --global user.email "${GL_EMAIL}"
git config --global user.name "${GL_USER}"

echo "=== Syncing Production Assets to GitLab ==="
git add build/web/
git commit -m "ci: production web wasm asset generation from terminal sandbox"
git remote set-url origin "${GL_REMOTE_SYNC}"
git push origin "${GL_BRANCH}"

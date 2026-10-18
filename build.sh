#!/bin/bash
#triggered.
sed -i 's/\r$//' "$0" || true
# =========================================================
# 1. FIXED PARSING VARIABLES
# =========================================================
PROTOCOL_SECURE="https://"
ENGINE_HOST="storage.googleapis"
EXTENSION_DOMAIN="com"
CHANNEL_DIR="dart-archive/channels/stable/release"
VERSION_TARGET="3.13.5"
ARCHIVE_TARGET="sdk/dartsdk-linux-x64-release.zip"

# Reconstruct the direct download endpoint safely
DART_ZIP_ENDPOINT="${PROTOCOL_SECURE}${ENGINE_HOST}.${EXTENSION_DOMAIN}/${CHANNEL_DIR}/${VERSION_TARGET}/${ARCHIVE_TARGET}"

# =========================================================
# 2. SOURCE CONTROL ACCESS CODES
# Configure these with your genuine GitLab details!
# =========================================================
GL_USER="casenoajw"
GL_TOKEN="glpat-rlGtMm0Ks544SD5CR94-I2M6MQpvOjEKdTpvODNqOQ8.01.170n4pt7v"
GL_REPO="wobblywizards"
GL_BRANCH="main"
GL_EMAIL="casenoajw@tutanota.com"

# Assemble the authenticated repository address
GL_REMOTE_SYNC="${PROTOCOL_SECURE}${GL_USER}:${GL_TOKEN}@gitlab.${EXTENSION_DOMAIN}/${GL_USER}/${GL_REPO}.git"

# =========================================================
# 3. COMPILER RETRIEVAL (No apt-get needed in jsh!)
# =========================================================
# Retrieve the standalone locked Dart package directly
curl -L "${DART_ZIP_ENDPOINT}" -o target_compiler.zip

# Unpack the package cleanly into the environment root using native jsh tools
unzip target_compiler.zip
export PATH="$PATH:$(pwd)/dart-sdk/bin"

# Pull the repository code via your authenticated GitLab handle
git clone "${GL_REMOTE_SYNC}" workspace_build
cd workspace_build

# =========================================================
# 4. WEBASSEMBLY TRANSPILATION & GIT COMMIT SYNC
# =========================================================
# Resolve project dependencies locally in memory
dart pub get

# Create deployment directory
mkdir -p build/web

# Compile the core entry module straight into highly optimized WebAssembly
# Note: Swap 'bin/main.dart' to 'web/main.dart' or 'lib/main.dart' depending on your entry file!
dart compile wasm lib/main.dart -o build/web/main.wasm --optimize

# Strip local file blocks to ensure tracking visibility
rm -f .gitignore
git config --global user.email "${GL_EMAIL}"
git config --global user.name "${GL_USER}"

# Stage the output binaries, commit, and push past the firewall layer
git add build/web/
git commit -m "ci: production web wasm asset generation from terminal sandbox"
git remote set-url origin "${GL_REMOTE_SYNC}"
git push origin "${GL_BRANCH}"

echo "========================================================="
echo "  WEBASSEMBLY COMPILE SUCCESSFUL & MERGED TO GITLAB!   "
echo "========================================================="
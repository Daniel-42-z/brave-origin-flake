#!/usr/bin/env bash
set -euo pipefail

# URL of the APT repository packages file
PACKAGES_URL="https://brave-browser-apt-release.s3.brave.com/dists/stable/main/binary-amd64/Packages"

# Fetch the Packages file
PACKAGES=$(curl -s "$PACKAGES_URL")

# Extract the version and filename for brave-origin
# We look for the brave-origin package block
BLOCK=$(echo "$PACKAGES" | awk -v RS= '/Package: brave-origin/{print; exit}')

if [ -z "$BLOCK" ]; then
    echo "Could not find brave-origin in APT repository."
    exit 1
fi

VERSION=$(echo "$BLOCK" | grep '^Version:' | awk '{print $2}')
FILENAME=$(echo "$BLOCK" | grep '^Filename:' | awk '{print $2}')

if [ -z "$VERSION" ] || [ -z "$FILENAME" ]; then
    echo "Could not parse version or filename."
    exit 1
fi

DEB_URL="https://brave-browser-apt-release.s3.brave.com/$FILENAME"

echo "Latest brave-origin version is $VERSION"

# Read the current version from versions.json if it exists
if [ -f versions.json ]; then
    CURRENT_VERSION=$(jq -r '."brave-origin".version // empty' versions.json)
    if [ "$CURRENT_VERSION" == "$VERSION" ]; then
        echo "Already up to date."
        exit 0
    fi
fi

echo "Fetching new version and generating hash..."
# We use nix store prefetch-file to get the SRI hash
HASH=$(nix store prefetch-file --json "$DEB_URL" | jq -r .hash)

# Update versions.json
cat <<EOF > versions.json
{
  "brave-origin": {
    "version": "$VERSION",
    "url": "$DEB_URL",
    "hash": "$HASH"
  }
}
EOF

echo "Updated versions.json with version $VERSION"

#!/usr/bin/env bash
# Builds the IBM Cloud VPC connector (a community project) as a local Docker image named "ibmcloud-vpc-mcp".
# Source: https://github.com/greyhoundforty/ibmcloud-vpc-mcp
set -euo pipefail
cd "$(dirname "$0")/.."

REPO_URL="https://github.com/greyhoundforty/ibmcloud-vpc-mcp.git"
DIR=".build/ibmcloud-vpc-mcp"

if [ -d "$DIR/.git" ]; then
  echo "Updating the connector source…"
  git -C "$DIR" pull --ff-only
else
  echo "Downloading the connector source…"
  mkdir -p .build
  git clone --depth 1 "$REPO_URL" "$DIR"
fi

echo "Building the Docker image (this can take a minute)…"
docker build -t ibmcloud-vpc-mcp "$DIR"
echo "Done. The IBM Cloud connector is ready."

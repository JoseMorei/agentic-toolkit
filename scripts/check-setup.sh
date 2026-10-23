#!/usr/bin/env bash
# Checks that the tools this kit needs are installed and that your keys are set.
# It never prints the keys themselves.
set -u
cd "$(dirname "$0")/.."

ok()   { printf '  \033[32m✔\033[0m %s\n' "$1"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$1"; }
bad()  { printf '  \033[31m✘\033[0m %s\n' "$1"; }

echo "Programs"
for tool in claude docker kubectl; do
  if command -v "$tool" >/dev/null 2>&1; then ok "$tool is installed"
  elif [ "$tool" = kubectl ]; then warn "kubectl not found (only needed for the Kubernetes checks)"
  else bad "$tool not found"; fi
done
if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then ok "Docker is running"; else bad "Docker is installed but not running"; fi
  if docker image inspect ibmcloud-vpc-mcp >/dev/null 2>&1; then ok "IBM Cloud connector image is built"
  else warn "IBM Cloud connector not built yet (run ./scripts/build-ibm-vpc-mcp.sh if you use IBM Cloud)"; fi
fi

echo "Keys"
if [ -f .env ]; then
  set -a; . ./.env; set +a
  ok ".env file found"
else
  warn "no .env file yet (run: cp .env.example .env, then add your keys)"
fi
check_key() { if [ -n "${!1:-}" ]; then ok "$2 key is set"; else warn "$2 key is empty, so the $2 connector won't work"; fi; }
check_key PAGERDUTY_API_KEY "PagerDuty"
check_key GITHUB_PERSONAL_ACCESS_TOKEN "GitHub"
check_key ENV0_API_KEY "env0"
check_key IBMCLOUD_API_KEY "IBM Cloud"

echo
echo "When you're ready:  set -a; source .env; set +a; claude"

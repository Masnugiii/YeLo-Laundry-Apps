#!/usr/bin/env bash
set -euo pipefail

# Run YeLo Laundry Internal on a physical Android device for development.
# API host is auto-detected from the Mac LAN IP (same Wi-Fi as NestJS).
#
# Usage:
#   ./scripts/run-yelo-internal-physical-preview.sh
#   ./scripts/run-yelo-internal-physical-preview.sh -d <device-id>
#
# Prerequisites:
#   1. NestJS: npm run start:dev  (APP_HOST=0.0.0.0, port 3000)
#   2. Phone + Mac on the same Wi-Fi
#   3. USB debugging enabled (or wireless adb)
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/flutter-run-mobile.sh" physical staff "$@"

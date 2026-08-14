#!/usr/bin/env bash
set -euo pipefail

# Build YeLo Laundry Internal release APK for physical-device / outlet Wi-Fi testing.
# Uses the current Mac LAN IP (not production HTTPS).
#
# For store/production builds use:
#   ./scripts/flutter-build-mobile-apk.sh production staff
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/flutter-build-mobile-apk.sh" physical staff "$@"

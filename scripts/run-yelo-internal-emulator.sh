#!/usr/bin/env bash
set -euo pipefail

# Run YeLo Laundry Internal (Staff ERP) on Android emulator.
# API target: http://10.0.2.2:3000/api/v1 (see config/api/emulator.json)
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/flutter-run-mobile.sh" emulator staff "$@"

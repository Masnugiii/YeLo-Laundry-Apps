#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/api-define.sh
source "$ROOT_DIR/scripts/lib/api-define.sh"

PROFILE="${1:-emulator}"
APP="${2:-staff}"

case "$PROFILE" in
  emulator)
    DEFINE_FILE="$ROOT_DIR/config/api/emulator.json"
    ;;
  physical|physical-android|internal|internal-wifi)
    LOCAL_DEFINE="$ROOT_DIR/config/api/physical-android.local.json"
    LAN_IP="$(detect_lan_ip || true)"
    DEFINE_FILE="$(write_physical_define_file "$ROOT_DIR" "$LOCAL_DEFINE" "$LAN_IP")"
    if [[ -n "$LAN_IP" ]]; then
      sync_android_cleartext_lan_domain "$ROOT_DIR" "$LAN_IP"
    fi
    ;;
  *)
    echo "Unknown profile: $PROFILE" >&2
    echo "Usage: $0 [emulator|physical] [staff|customer]" >&2
    exit 1
    ;;
esac

case "$APP" in
  staff)
    APP_DIR="$ROOT_DIR"
    ;;
  customer)
    APP_DIR="$ROOT_DIR/customer_app"
    ;;
  *)
    echo "Unknown app: $APP" >&2
    echo "Usage: $0 [emulator|physical] [staff|customer]" >&2
    exit 1
    ;;
esac

echo "Using dart-define file: $DEFINE_FILE" >&2
cd "$APP_DIR"
flutter run --dart-define-from-file="$DEFINE_FILE" "${@:3}"

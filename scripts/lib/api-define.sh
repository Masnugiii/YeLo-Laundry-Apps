#!/usr/bin/env bash
# Shared helpers for Staff/Customer Flutter API dart-defines.
# shellcheck shell=bash

detect_lan_ip() {
  local ip=""
  if command -v ipconfig >/dev/null 2>&1; then
    for iface in en0 en1 en2 en3; do
      ip="$(ipconfig getifaddr "$iface" 2>/dev/null || true)"
      if [[ -n "$ip" ]]; then
        echo "$ip"
        return 0
      fi
    done
  fi

  if command -v hostname >/dev/null 2>&1; then
    ip="$(hostname -I 2>/dev/null | awk '{print $1}' || true)"
    if [[ -n "$ip" ]]; then
      echo "$ip"
      return 0
    fi
  fi

  return 1
}

write_physical_define_file() {
  local root_dir="$1"
  local out_file="$2"
  local lan_ip="${3:-}"

  if [[ -z "$lan_ip" ]]; then
    lan_ip="$(detect_lan_ip || true)"
  fi

  if [[ -z "$lan_ip" ]]; then
    echo "Could not detect Mac LAN IP. Falling back to config/api/physical-android.json" >&2
    echo "$root_dir/config/api/physical-android.json"
    return 0
  fi

  mkdir -p "$(dirname "$out_file")"
  cat >"$out_file" <<EOF
{
  "API_ENV": "physical",
  "API_BASE_URL": "http://${lan_ip}:3000/api/v1",
  "API_HOST": "${lan_ip}"
}
EOF
  echo "Resolved physical Android API host: ${lan_ip}" >&2
  echo "$out_file"
}

sync_android_cleartext_lan_domain() {
  local root_dir="$1"
  local lan_ip="$2"
  local nsc="$root_dir/android/app/src/main/res/xml/network_security_config.xml"

  if [[ -z "$lan_ip" || ! -f "$nsc" ]]; then
    return 0
  fi

  # Keep emulator/localhost domains; replace any previous 192.168.* cleartext domain.
  python3 - "$nsc" "$lan_ip" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
lan_ip = sys.argv[2]
text = path.read_text()

domain_line = f'        <domain includeSubdomains="false">{lan_ip}</domain>'
pattern = re.compile(
    r'        <domain includeSubdomains="false">192\.168\.\d+\.\d+</domain>\n?'
)
if pattern.search(text):
    text = pattern.sub(domain_line + "\n", text, count=1)
elif lan_ip not in text:
    needle = '        <domain includeSubdomains="false">127.0.0.1</domain>'
    if needle in text:
        text = text.replace(
            needle,
            needle + "\n" + domain_line,
            1,
        )
path.write_text(text)
print(f"Updated cleartext LAN domain in {path} → {lan_ip}", file=sys.stderr)
PY
}

assert_production_api_url() {
  local url="$1"
  local lower
  lower="$(printf '%s' "$url" | tr '[:upper:]' '[:lower:]')"
  if [[ "$lower" != https://* ]]; then
    echo "Production API_BASE_URL must use HTTPS: $url" >&2
    exit 1
  fi
  if [[ "$lower" == *://localhost* || "$lower" == *://127.0.0.1* || "$lower" == *://10.0.2.2* ]]; then
    echo "Production API_BASE_URL must not use localhost/10.0.2.2: $url" >&2
    exit 1
  fi
}

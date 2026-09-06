#!/usr/bin/env bash
# Collects basic hardware/system info from the local machine and writes it
# to hardware-info/<hostname>.md. Run this ON the target machine (e.g. miniPC),
# then commit and push the resulting file so it's readable from any other
# computer via the repo.
#
# Usage: ./hardware-info/collect.sh

set -euo pipefail

cd "$(dirname "$0")"

HOSTNAME_SAFE=$(hostname | tr -cd '[:alnum:]-_')
OUT="${HOSTNAME_SAFE:-unknown-host}.md"

{
  echo "# Dane sprzętowe: $(hostname)"
  echo
  echo "Zebrano: $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
  echo
  echo "## System"
  echo '```'
  uname -a 2>/dev/null || true
  [ -f /etc/os-release ] && cat /etc/os-release
  echo '```'
  echo
  echo "## CPU"
  echo '```'
  if command -v lscpu >/dev/null 2>&1; then
    lscpu
  else
    cat /proc/cpuinfo 2>/dev/null | head -n 40
  fi
  echo '```'
  echo
  echo "## Pamięć RAM"
  echo '```'
  free -h 2>/dev/null || true
  echo '```'
  echo
  echo "## Dyski"
  echo '```'
  lsblk 2>/dev/null || true
  echo
  df -h 2>/dev/null || true
  echo '```'
  echo
  echo "## PCI / urządzenia"
  echo '```'
  lspci 2>/dev/null || echo "lspci niedostępne"
  echo '```'
  echo
  echo "## USB"
  echo '```'
  lsusb 2>/dev/null || echo "lsusb niedostępne"
  echo '```'
  echo
  echo "## Sieć"
  echo '```'
  ip -brief address 2>/dev/null || ifconfig 2>/dev/null || true
  echo '```'
  echo
  echo "## Temperatury / czujniki"
  echo '```'
  sensors 2>/dev/null || echo "lm-sensors niedostępne (zainstaluj: sudo apt install lm-sensors)"
  echo '```'
} > "$OUT"

echo "Zapisano dane do hardware-info/$OUT"
echo "Teraz zrób: git add hardware-info/$OUT && git commit -m 'Add hardware info for $(hostname)' && git push"

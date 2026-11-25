#!/usr/bin/env bash
set -euo pipefail
echo "rEFInd Legacy BIOS - Linux physical disk selector"
if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo to enumerate physical disks." >&2
  exit 2
fi
lsblk -e7 -o NAME,PATH,MODEL,SERIAL,SIZE,TYPE,FSTYPE,MOUNTPOINTS
echo
echo "No disk has been modified."
echo "Required repository payloads:"
printf '%s\n' "payloads/DUET/boot6/boot" "payloads/DUET/boot7/boot" "payloads/BootSectors/boot0ss" "payloads/BootSectors/boot1f32"
echo "This installer is intentionally read-only until safe, layout-specific MBR/GPT sector writing is implemented and tested."
exit 3

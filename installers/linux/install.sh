#!/usr/bin/env bash
set -euo pipefail
echo "rEFInd Legacy BIOS - Linux physical disk selector"
if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo to enumerate physical disks." >&2
  exit 2
fi
lsblk -e7 -o NAME,PATH,MODEL,SERIAL,SIZE,TYPE,FSTYPE,MOUNTPOINTS
echo
echo "Built boot-sector outputs: boot0af, boot0ss, boot1f32, boot1f32alt"
echo "Read-only preview: no disk has been modified."
echo "Sector writing remains disabled pending verified MBR/GPT layout-specific logic."
exit 3

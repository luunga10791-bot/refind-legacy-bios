#!/usr/bin/env bash
# rEFInd Legacy BIOS - guarded MBR boot0 installer.
set -Eeuo pipefail
die() { echo "ERROR: $*" >&2; exit 1; }
[[ $EUID -eq 0 ]] || die "Run with sudo."
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
find_binary() {
  local name="$1" candidate
  for candidate in "$SCRIPT_DIR/payloads/BootSectors/$name" "$SCRIPT_DIR/../../payloads/BootSectors/$name" "$SCRIPT_DIR/../payloads/BootSectors/$name"; do
    if [[ -f "$candidate" ]]; then readlink -f -- "$candidate"; return 0; fi
  done
  return 1
}
echo "Physical disks:"
lsblk -d -e7 -o NAME,PATH,MODEL,SERIAL,SIZE,RO,TYPE
echo
read -r -p "Enter target whole-disk device (example /dev/sdb): " DISK
[[ -b "$DISK" ]] || die "Not a block device."
DISK="$(readlink -f -- "$DISK")"
[[ "$(lsblk -dn -o TYPE "$DISK" | tr -d ' ')" == "disk" ]] || die "Select a whole physical disk."
[[ "$(blockdev --getro "$DISK")" == "0" ]] || die "Target disk is read-only."
[[ "$(blockdev --getss "$DISK")" == "512" ]] || die "Only 512-byte logical-sector disks are supported."
ROOT_SOURCE="$(findmnt -n -o SOURCE / | sed 's/\[.*$//')"
if [[ -b "$ROOT_SOURCE" ]]; then
  ROOT_DISK="$(lsblk -s -n -o PATH,TYPE "$ROOT_SOURCE" | awk '$2=="disk"{print $1; exit}')"
  [[ "$ROOT_DISK" != "$DISK" ]] || die "Refusing to modify the disk containing root."
fi
while IFS= read -r mp; do [[ -z "$mp" ]] || die "Target disk has a mounted partition: $mp"; done < <(lsblk -nr -o MOUNTPOINT "$DISK" | sed '/^[[:space:]]*$/d')
PTTYPE="$(lsblk -dn -o PTTYPE "$DISK" | tr -d '[:space:]')"
[[ "$PTTYPE" == "dos" || "$PTTYPE" == "gpt" ]] || die "Unsupported/missing partition table: $PTTYPE"
echo; echo "1 - boot0af (active partition first)"; echo "2 - boot0ss (scan supported partitions)"
read -r -p "Select 1 or 2: " CHOICE
case "$CHOICE" in 1) BOOT_NAME=boot0af ;; 2) BOOT_NAME=boot0ss ;; *) die "Invalid selection." ;; esac
BOOT_FILE="$(find_binary "$BOOT_NAME")" || die "Cannot find payloads/BootSectors/$BOOT_NAME."
[[ "$(wc -c < "$BOOT_FILE")" -eq 512 ]] || die "$BOOT_NAME must be 512 bytes."
ORIGINAL="$(mktemp)"; PATCHED="$(mktemp)"; VERIFY=""
trap 'rm -f "$ORIGINAL" "$PATCHED" "$VERIFY"' EXIT
dd if="$DISK" of="$ORIGINAL" bs=512 count=1 status=none
[[ "$(wc -c < "$ORIGINAL")" -eq 512 ]] || die "Could not read sector 0."
SIG="$(od -An -tx1 -j510 -N2 "$ORIGINAL" | tr -d ' \n')"
[[ "$SIG" == "55aa" ]] || die "No valid 0xAA55 MBR signature."
PARTS="$(od -An -tx1 -j446 -N64 "$ORIGINAL" | tr -d ' \n0')"
[[ -n "$PARTS" ]] || die "No partition entries found."
cp "$ORIGINAL" "$PATCHED"
dd if="$BOOT_FILE" of="$PATCHED" bs=1 count=440 conv=notrunc status=none
MODEL="$(lsblk -dn -o MODEL "$DISK" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
SIZE="$(lsblk -dn -o SIZE "$DISK" | tr -d '[:space:]')"
BACKUP_DIR="/var/backups/refind-legacy-bios"; install -d -m 700 "$BACKUP_DIR"
BACKUP="$BACKUP_DIR/$(basename "$DISK")-sector0-$(date +%Y%m%d-%H%M%S).bin"
cp "$ORIGINAL" "$BACKUP"; chmod 600 "$BACKUP"
echo; echo "Target: $DISK | $MODEL | $SIZE | $PTTYPE"; echo "Boot code: $BOOT_NAME"
echo "Backup: $BACKUP"; echo "Only bytes 0-439 change; bytes 440-511 are preserved."
read -r -p "Type the exact device path '$DISK' to authorize: " CONFIRM
[[ "$CONFIRM" == "$DISK" ]] || die "Confirmation mismatch; no changes made."
read -r -p "Type INSTALL to write: " CONFIRM2
[[ "$CONFIRM2" == "INSTALL" ]] || die "Final confirmation mismatch; no changes made."
if ! dd if="$PATCHED" of="$DISK" bs=512 count=1 conv=notrunc,fsync status=none; then
  dd if="$ORIGINAL" of="$DISK" bs=512 count=1 conv=notrunc,fsync status=none || die "Write and automatic restore failed; restore from $BACKUP."
  die "Write failed; original sector restored."
fi
VERIFY="$(mktemp)"; dd if="$DISK" of="$VERIFY" bs=512 count=1 status=none
if ! cmp -s "$PATCHED" "$VERIFY"; then
  dd if="$ORIGINAL" of="$DISK" bs=512 count=1 conv=notrunc,fsync status=none || die "Verification and automatic restore failed; restore from $BACKUP."
  die "Verification failed; original sector restored."
fi
echo "SUCCESS: $BOOT_NAME installed on $DISK."; echo "Backup: $BACKUP"

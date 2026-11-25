#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
command -v nasm >/dev/null || { echo "NASM is required" >&2; exit 1; }
make clean all
for f in build/*; do
  size=$(wc -c < "$f")
  if [[ "$size" -ne 512 ]]; then echo "Invalid boot-sector size: $f ($size bytes)" >&2; exit 1; fi
done

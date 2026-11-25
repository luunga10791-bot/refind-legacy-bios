# rEFInd Legacy BIOS (Clover DUET)

Experimental packaging project for the chain:

`Legacy BIOS → MBR/PBR boot code → Clover DUET (boot6 or boot7) → rEFInd x64 EFI application`.

## Build variants

- **DUET boot6**: CloverEFI x64 using the normal BIOS access path.
- **DUET boot7**: CloverEFI x64 using BIOS Block I/O (MCP compatibility path).
- **Boot-sector payloads**: Clover-generated MBR and FAT32 PBR binaries available from upstream.
- **rEFInd**: x64 EFI application staged at `EFI/BOOT/BOOTX64.EFI`.

These are payloads, not an installer or a ready-to-write disk image. They do not guarantee that every MBR/GPT partition layout is bootable. In particular, `boot1f32` is for FAT32 PBR booting, not a universal GPT boot sector. Never overwrite a disk's MBR/PBR without backing it up and preserving its partition table and FAT32 BPB.

## CI

Push, pull request, or manual dispatch builds an artifact. Pushing a tag matching `v*` is intended to publish a GitHub Release. The first workflow run is an integration test; upstream build and distribution changes may require maintenance.

## Upstream projects

- [CloverBootloader](https://github.com/CloverHackyColor/CloverBootloader)
- [rEFInd](https://github.com/rhboot/refind)
- [rEFInd documentation](https://www.rodsbooks.com/refind/)

## Licensing

This repository contains build and packaging glue. CloverBootloader and rEFInd retain their respective upstream licenses; consult those projects for their full terms.

# Vendored Clover boot-sector subset

Source: [Clover-EFI-Bootloader/clover](https://github.com/Clover-EFI-Bootloader/clover), directory `BootHFS`, master branch, imported 2026-11-25.

Included only the common MBR code and FAT32 partition boot sectors needed for this project's current Legacy BIOS experiment:

- `boot0.s`, `boot0af.s`, `boot0ss.s`
- `boot1f32.s`, `boot1f32alt.s`
- `Makefile`, `build.sh`

NASM builds four 512-byte outputs: `boot0af`, `boot0ss`, `boot1f32`, `boot1f32alt`. The MBR boot0 variants include hybrid MBR/GPT scanning logic; this does not make every GPT layout bootable. FAT32 PBR code expects BIOS EBIOS/LBA support and a root-level stage-2 file named `boot` (or variant for alt).

The assembly source retains its original Apple Public Source License 2.0 notices. Preserve those notices and consult the license before redistribution. This subset does not include DUET boot6/boot7 or rEFInd binaries.

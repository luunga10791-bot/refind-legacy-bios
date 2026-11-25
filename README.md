# rEFInd Legacy BIOS - boot-sector subset

This repository vendors and builds only Clover-derived Legacy BIOS MBR and FAT32 partition boot-sector source. DUET boot6/boot7 are deliberately out of scope.

## Included source

The vendor/clover-bootsector directory contains the minimal source subset copied from Clover-EFI-Bootloader/clover, BootHFS directory:

- boot0.s: shared MBR implementation.
- boot0af.s: active-partition-first MBR variant.
- boot0ss.s: signature-scanning MBR variant.
- boot1f32.s: FAT32 partition boot sector; loads a root-level file named boot.
- boot1f32alt.s: FAT32 alternate-key variant.
- Makefile and build.sh: NASM build and 512-byte output validation.

## Build and release

On Linux with NASM and Make installed:

    cd vendor/clover-bootsector
    ./build.sh

GitHub Actions builds from this repository only; it does not clone Clover or download rEFInd.

Release assets:
- install-windows.zip: extract, then run install.bat as Administrator (Windows PowerShell 2.0+ compatible).
- install-linux.tar.gz: extract, then run sudo bash install.sh.
- refind-legacy-bios-bootsectors.tar.gz: complete source, binaries and installer tree.

## Installer behavior

The Windows and Linux installers let the user select boot0af or boot0ss and a physical disk. They validate the sector signature and partition entries, create a full 512-byte sector backup, require two typed confirmations, write the new 440-byte MBR boot-code region, and read back the sector. Bytes 440-511 (disk signature, partition table and MBR signature) are preserved. Windows refuses the current boot/system disk; Linux refuses the root disk and any disk with mounted partitions.

The scripts support only 512-byte logical-sector disks with an existing MBR partition table. GPT MBR boot compatibility depends on the hybrid/protective layout, firmware and target partition arrangement; universal GPT boot support is not guaranteed. Test on disposable media or a VM first.

boot1f32 and boot1f32alt are built but are not written by the current installers. Their FAT32 BPB-preserving installation needs a separate validated procedure. The FAT32 loader expects a compatible stage-2 file named boot in the partition root and BIOS EBIOS/LBA support.

No refind.efi, DUET boot6 or boot7 is included. The user supplies the EFI/DUET chain components separately.

## Licensing and provenance

The imported assembly retains its Apple Public Source License 2.0 notices. Read and comply with the license before redistribution. Upstream provenance is documented in vendor/clover-bootsector/README.md.

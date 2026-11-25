# Boot-sector installation safety

The project builds Clover-derived MBR and FAT32 partition boot-sector binaries:

- boot0af: active-partition-first MBR selector.
- boot0ss: partition-signature-scanning MBR selector.
- boot1f32 and boot1f32alt: FAT32 partition boot sectors that load a stage-2 file from the FAT32 root.

## Current installer behavior

Windows PowerShell and Linux Bash installers can install either MBR variant. They:
- enumerate physical disks and require an explicit whole-disk selection;
- require 512-byte logical sectors, an existing partition table and a valid 0xAA55 MBR signature;
- refuse the current Windows boot/system disk (Windows) and the root disk or any disk with mounted partitions (Linux);
- save the original complete 512-byte sector before writing;
- require the exact disk identifier and a second INSTALL confirmation;
- replace only bytes 0-439, preserving bytes 440-511 (including disk signature, partition table and MBR signature);
- read back the sector and attempt automatic restoration if verification fails.

The installers do not format, repartition, change GPT headers or install the FAT32 PBR. They support only 512-byte logical-sector devices. GPT boot compatibility is layout- and firmware-dependent and must not be assumed. Test using disposable disk images/VMs before using real media.

## FAT32 PBR remains separate

The FAT32 PBR installation is not enabled. Any future implementation must preserve the BPB and filesystem metadata, validate FAT32 geometry and partition offsets, back up the target partition's first sector, and verify the correct byte ranges before writing. The boot1f32 loader expects a compatible stage-2 file named boot in the FAT32 root and BIOS EBIOS/LBA support.

No DUET boot6/boot7 or rEFInd EFI binary is distributed by this repository.

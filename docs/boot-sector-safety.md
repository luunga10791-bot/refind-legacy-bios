# Boot-sector installation safety

This project currently builds only Clover-derived MBR and FAT32 partition boot-sector binaries:

- `boot0af`: active-partition-first MBR selector.
- `boot0ss`: partition-signature-scanning MBR selector.
- `boot1f32` and `boot1f32alt`: FAT32 partition boot sectors that load a stage-2 file from the FAT32 root.

The Windows and Linux installer entry points are intentionally read-only at this stage. They enumerate disks but do not write raw sectors.

## Required safeguards before enabling writes

- MBR boot code shares sector 0 with the partition table. Preserve bytes 446–509 and the MBR signature when updating only boot code; the exact code-region length must match the selected binary.
- GPT contains a protective MBR, GPT headers and partition-entry arrays. Clover's MBR variants have hybrid MBR/GPT scanning logic, but this is not universal support for every GPT layout or BIOS.
- FAT32 PBR replacement must preserve the existing BPB and filesystem metadata. The upstream Clover installation instructions preserve the BPB bytes at offsets 3–89; verify this against the exact binary before writing.
- Back up the exact sectors before writes, display disk identity and layout, require typed confirmation, and abort for the system/root disk or unsupported filesystems.
- Never format, repartition, or modify GPT metadata automatically.
- FAT32 PBR code expects BIOS EBIOS/LBA support and a compatible stage-2 file named `boot` in the partition root.
- Validate each MBR variant and FAT32 PBR combination in disposable disk images and BIOS-mode virtual machines before enabling writes.

The Release does not include DUET boot6/boot7 or rEFInd. The user supplies the EFI/DUET chain components separately.

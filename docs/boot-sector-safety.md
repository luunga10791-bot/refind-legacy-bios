# Boot-sector installation safety

This repository's installer entry points are fail-closed until reviewed payloads and disk-layout-specific write logic are present. They must not guess partition offsets or write raw sectors based only on a disk number.

- MBR boot code shares sector 0 with the partition table. Preserve bytes 446–509 and the signature when updating only boot code.
- GPT includes a protective MBR, GPT headers and partition-entry arrays. Legacy BIOS boot on GPT requires a deliberately supported layout and firmware path; do not treat an MBR payload as generic GPT support.
- FAT32 PBR replacement must preserve the existing BPB and filesystem metadata. Never blindly overwrite a full 512-byte PBR.
- Back up the exact sectors before writes, display disk identity and layout, require typed confirmation, and abort for the system/root disk or unsupported filesystems.
- Never format, repartition, or modify GPT metadata automatically.
- Validate each boot6/boot7 + MBR/GPT combination in disposable disk images and BIOS-mode virtual machines before enabling writes.

The release does not include rEFInd. The user supplies the EFI application separately.

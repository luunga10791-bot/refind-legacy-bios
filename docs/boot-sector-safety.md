# Boot-sector components and installation safety

This project publishes Clover's boot-sector binaries as reference payloads. It deliberately does not provide a script that writes raw sectors to a physical disk.

## MBR and GPT are not interchangeable boot-sector formats

- An MBR disk has executable code in the MBR's boot-code area and a partition table in the same 512-byte sector. Replacing the entire sector can destroy the partition table.
- GPT disks normally retain a protective MBR, GPT headers and partition-entry arrays. Legacy BIOS booting from GPT additionally depends on firmware, boot code and a supported partition/filesystem arrangement. A boot-sector binary alone does not make arbitrary GPT layouts bootable.
- A FAT32 partition boot sector (PBR) is not the same thing as an MBR. Clover's `boot1f32` / `boot1f32alt` are FAT32-oriented partition boot components, not generic GPT installers.

## FAT32 BPB preservation

When replacing a FAT32 PBR, preserve the existing volume's BIOS Parameter Block (BPB). Clover's own installation notes describe copying the BPB region from the original sector; do not blindly write a complete 512-byte template over an existing filesystem boot sector.

## Required validation before real hardware

1. Use a disposable virtual disk image, never the only copy of important data.
2. Test MBR and GPT layouts separately in a BIOS-mode virtual machine.
3. Test boot6 and boot7 as separate DUET variants.
4. Confirm the DUET stage can locate and load the rEFInd EFI application.
5. Record firmware settings, partition layout, filesystem and exact boot-sector variant for every successful test.

Until these tests are automated and passing, release artifacts should be treated as experimental components, not a validated installer or turnkey boot disk.

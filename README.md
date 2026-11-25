# rEFInd Legacy BIOS (Clover DUET)

Experimental, repository-local packaging for a Legacy BIOS → boot-sector → Clover DUET → rEFInd chain.

## Release contents

- Windows launcher: `install-windows.bat` and PowerShell implementation.
- Linux installer: `install-linux.sh`.
- Clover DUET boot6 and boot7 payloads and boot-sector components stored under `payloads/`.
- **No `refind.efi` is bundled.** Download rEFInd separately and copy its x64 EFI application to `EFI/BOOT/BOOTX64.EFI` on the EFI System Partition.

## Disk selection and safety

The Windows installer enumerates physical disks as `PhysicalDriveN`; Linux enumerates block devices such as `/dev/sda` and prefers stable `/dev/disk/by-id/` names. The intended workflow is to show disk model/size/partitions, require an explicit typed confirmation, back up sectors, and refuse unsupported layouts. It must never format a disk or overwrite an entire MBR/PBR sector without preserving partition metadata/BPB.

**Important:** MBR and GPT are not interchangeable. Clover FAT32 PBR components are not universal GPT boot code. The current scripts are fail-closed until the required, reviewed binary payloads are present; do not treat the package as a validated one-click installer until MBR and GPT have each passed disposable-disk BIOS tests.

## Repository-only CI

GitHub Actions checks out this repository only. It does not clone CloverBootloader, download rEFInd, or fetch third-party build inputs. Consequently, the binary files below must be committed into this repository before a Release can be packaged:

```
payloads/
  DUET/boot6/boot
  DUET/boot7/boot
  BootSectors/boot0ss
  BootSectors/boot1f32
```

Keep upstream license and provenance notices alongside imported binaries. The workflow intentionally fails if required payloads are absent rather than silently publishing incomplete assets.

## Licensing

CloverBootloader components retain their upstream license. See the relevant upstream notices before redistributing binaries. rEFInd is distributed separately by its own project.

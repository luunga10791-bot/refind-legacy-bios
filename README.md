# rEFInd Legacy BIOS - boot-sector subset

This repository currently vendors and builds only the Clover-derived Legacy BIOS MBR and FAT32 partition boot-sector source. DUET boot6/boot7 are deliberately out of scope for now.

## Included source

`vendor/clover-bootsector/` contains the minimal source subset copied from [Clover-EFI-Bootloader/clover](https://github.com/Clover-EFI-Bootloader/clover), `BootHFS` directory:

- `boot0.s`: shared MBR implementation.
- `boot0af.s`: active-partition-first MBR variant.
- `boot0ss.s`: signature-scanning MBR variant.
- `boot1f32.s`: FAT32 partition boot sector, loads a root-level file named `boot`.
- `boot1f32alt.s`: FAT32 alternate-key variant.
- `Makefile` and `build.sh`: NASM build and 512-byte output validation.
- Original source license headers and upstream descriptions are retained.

## Build

On Linux with NASM and Make installed:

```sh
cd vendor/clover-bootsector
./build.sh
```

Outputs are placed in `vendor/clover-bootsector/build/`. GitHub Actions builds from this repository only; it does not clone Clover or download rEFInd.

## Release

The Release packages the four boot-sector binaries, their vendored source, and Windows/Linux installer entry points. **No `refind.efi`, boot6 or boot7 is included.**

The installers are currently read-only previews. They enumerate physical disks but do not write sectors until disk-layout-specific installation and recovery logic has been tested.

## MBR/GPT and safety

The MBR variants contain hybrid MBR/GPT partition scanning logic, but this does not guarantee compatibility with every GPT layout or BIOS. FAT32 PBR requires BIOS EBIOS/LBA support and a compatible FAT32 partition. When installing, preserve the MBR partition table and FAT32 BPB; never overwrite an entire sector blindly or format the target automatically. Test using disposable disk images/VMs first.

## Licensing and provenance

The imported assembly retains its Apple Public Source License 2.0 notices. Read and comply with the license before redistribution. Upstream provenance is documented in `vendor/clover-bootsector/README.md`.

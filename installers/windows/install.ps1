# Fail-closed entry point. Raw-sector installation is not enabled yet.
$ErrorActionPreference = 'Stop'
Write-Host "rEFInd Legacy BIOS - Windows physical disk selector"
Write-Host "Boot-sector binaries are built from vendor\clover-bootsector."
Write-Host "This installer is read-only; no disk will be modified."
try {
  Get-Disk | Sort-Object Number | Format-Table Number, FriendlyName, SerialNumber, BusType, PartitionStyle, @{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}} -AutoSize
} catch {
  Write-Error "Cannot enumerate physical disks. Run in an elevated PowerShell window."
  exit 2
}
Write-Host "Supported build outputs: boot0af, boot0ss, boot1f32, boot1f32alt."
Write-Host "Sector writing is disabled pending verified MBR/GPT layout-specific logic."
exit 3

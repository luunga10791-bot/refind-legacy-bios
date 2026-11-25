# Fail-closed entry point. Raw-sector installation is deliberately disabled
# until repository-local Clover payloads and tested MBR/GPT layouts are supplied.
$ErrorActionPreference = 'Stop'
Write-Host "rEFInd Legacy BIOS - Windows physical disk selector"
Write-Host "This release is not yet authorized to write boot sectors."
Write-Host "No disk has been modified."
try {
  Get-Disk | Sort-Object Number | Format-Table Number, FriendlyName, SerialNumber, BusType, PartitionStyle, @{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}} -AutoSize
} catch {
  Write-Error "Cannot enumerate physical disks. Run in an elevated PowerShell window."
  exit 2
}
Write-Host ""
Write-Host "Required repository payloads: payloads\DUET\boot6\boot, payloads\DUET\boot7\boot,"
Write-Host "payloads\BootSectors\boot0ss and payloads\BootSectors\boot1f32."
Write-Host "The installer remains read-only until safe, layout-specific sector writing is implemented and tested."
exit 3

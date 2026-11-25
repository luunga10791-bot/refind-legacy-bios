# rEFInd Legacy BIOS - guarded MBR boot0 installer (Windows PowerShell 2.0+).
$ErrorActionPreference = 'Stop'
function Find-BootBinary($name, $scriptDir) {
  $candidates = @((Join-Path $scriptDir ("payloads\BootSectors\"+$name)),(Join-Path $scriptDir ("..\..\payloads\BootSectors\"+$name)),(Join-Path $scriptDir ("..\payloads\BootSectors\"+$name)))
  foreach ($candidate in $candidates) { $full=[IO.Path]::GetFullPath($candidate); if (Test-Path -LiteralPath $full -PathType Leaf) { return $full } }
  throw "Cannot find payloads\BootSectors\$name."
}
try {
  $identity=[Security.Principal.WindowsIdentity]::GetCurrent()
  $principal=New-Object Security.Principal.WindowsPrincipal($identity)
  if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw "Run PowerShell as Administrator." }
  $scriptDir=Split-Path -Parent $MyInvocation.MyCommand.Path
  $disks=@(Get-WmiObject Win32_DiskDrive | Sort-Object Index)
  if ($disks.Count -eq 0) { throw "No physical disks found." }
  Write-Host ""; Write-Host "Physical disks:"
  foreach ($d in $disks) { Write-Host ("[{0}] {1} | {2} | {3} GB | {4} bytes/sector" -f $d.Index,$d.Model,$d.DeviceID,[math]::Round(([double]$d.Size/1GB),2),$d.BytesPerSector) }
  $diskText=Read-Host "Enter disk number N (PhysicalDriveN)"
  if ($diskText -notmatch '^\d+$') { throw "Invalid disk number." }
  $diskNumber=[int]$diskText; $disk=$null
  foreach ($d in $disks) { if ([int]$d.Index -eq $diskNumber) { $disk=$d } }
  if ($null -eq $disk) { throw "PhysicalDrive$diskNumber not found." }
  if ([int]$disk.BytesPerSector -ne 512) { throw "Only 512-byte logical-sector disks are supported." }
  $systemParts=@(Get-WmiObject Win32_DiskPartition | Where-Object { $_.DiskIndex -eq $diskNumber -and ($_.BootPartition -or $_.SystemPartition) })
  if ($systemParts.Count -gt 0) { throw "Refusing to modify the current Windows boot/system disk." }
  Write-Host ""; Write-Host "1 - boot0af (active partition first)"; Write-Host "2 - boot0ss (scan supported partitions)"
  $choice=Read-Host "Select 1 or 2"
  if ($choice -eq "1") { $bootName="boot0af" } elseif ($choice -eq "2") { $bootName="boot0ss" } else { throw "Invalid selection." }
  $bootCode=[IO.File]::ReadAllBytes((Find-BootBinary $bootName $scriptDir))
  if ($bootCode.Length -ne 512) { throw "$bootName must be 512 bytes." }
  $devicePath="\\.\PhysicalDrive$diskNumber"
  $stream=New-Object IO.FileStream($devicePath,[IO.FileMode]::Open,[IO.FileAccess]::ReadWrite,[IO.FileShare]::ReadWrite)
  try {
    $original=New-Object byte[] 512
    [void]$stream.Seek(0,[IO.SeekOrigin]::Begin); $read=$stream.Read($original,0,512)
    if ($read -ne 512) { throw "Could not read sector 0." }
    if ($original[510] -ne 0x55 -or $original[511] -ne 0xAA) { throw "No valid 0xAA55 MBR signature; refusing." }
    $hasPartition=$false
    for ($i=446;$i -lt 510;$i++) { if ($original[$i] -ne 0) { $hasPartition=$true; break } }
    if (-not $hasPartition) { throw "No partition entries found; refusing." }
    $backupDir=Join-Path $env:USERPROFILE "refind-legacy-bios-backups"
    if (-not (Test-Path $backupDir)) { [void](New-Item -ItemType Directory -Path $backupDir) }
    $backup=Join-Path $backupDir ("PhysicalDrive{0}-sector0-{1}.bin" -f $diskNumber,(Get-Date -Format "yyyyMMdd-HHmmss"))
    [IO.File]::WriteAllBytes($backup,$original)
    $patched=New-Object byte[] 512; [Array]::Copy($original,$patched,512)
    # boot0 executable code is exactly bytes 0..439; preserve bytes 440..511.
    [Array]::Copy($bootCode,0,$patched,0,440)
    Write-Host ""; Write-Host ("Target: PhysicalDrive{0} | {1} | {2} GB" -f $diskNumber,$disk.Model,[math]::Round(([double]$disk.Size/1GB),2))
    Write-Host "Selected: $bootName"; Write-Host "Backup: $backup"
    Write-Host "Only bytes 0-439 will change; bytes 440-511 are preserved."
    $confirm=Read-Host "Type PhysicalDrive$diskNumber to authorize"
    if ($confirm -cne ("PhysicalDrive"+$diskNumber)) { throw "Confirmation mismatch; no changes made." }
    $confirm2=Read-Host "Type INSTALL to write"
    if ($confirm2 -cne "INSTALL") { throw "Final confirmation mismatch; no changes made." }
    [void]$stream.Seek(0,[IO.SeekOrigin]::Begin); $stream.Write($patched,0,512); $stream.Flush()
    [void]$stream.Seek(0,[IO.SeekOrigin]::Begin)
    $verify=New-Object byte[] 512; $read2=$stream.Read($verify,0,512)
    if ($read2 -ne 512 -or [Convert]::ToBase64String($verify) -ne [Convert]::ToBase64String($patched)) {
      [void]$stream.Seek(0,[IO.SeekOrigin]::Begin); $stream.Write($original,0,512); $stream.Flush()
      throw "Verification failed; original sector restored."
    }
    Write-Host ""; Write-Host "SUCCESS: $bootName installed on PhysicalDrive$diskNumber."
  } finally { $stream.Dispose() }
  exit 0
} catch { Write-Error $_.Exception.Message; exit 1 }

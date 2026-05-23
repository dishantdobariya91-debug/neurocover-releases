# NeuroCover Focus - Pilot Installer (NSIS, per-user install)
# No admin elevation needed. Bypasses Windows Installer policy restrictions.

$ErrorActionPreference = "Stop"
$VERSION = "0.1.5"
$EXE_NAME = "NeuroCover-Focus-0.1.5_x64-setup.exe"
$EXPECTED_SHA256 = "AA9245DA95E52074E14C9D7932C9BC5561A97027EE407CF42186D0D82B56E3EE"
$BASE_URL = "https://github.com/dishantdobariya91-debug/neurocover-releases/releases/download/v0.1.5"

Write-Host ""
Write-Host "NeuroCover Focus -- Pilot Installer" -ForegroundColor Cyan
Write-Host "Version $VERSION (per-user install)" -ForegroundColor Cyan
Write-Host ""

Write-Host "==> Checking system" -ForegroundColor Yellow
Write-Host "  + PowerShell $($PSVersionTable.PSVersion)"
Write-Host "  + OS: $((Get-CimInstance Win32_OperatingSystem).Caption)"
$arch = if ([Environment]::Is64BitOperatingSystem) { "64-bit" } else { "32-bit" }
Write-Host "  + Architecture: $arch"
if (-not [Environment]::Is64BitOperatingSystem) {
    Write-Host "ERROR: 64-bit Windows required" -ForegroundColor Red
    return
}

Get-Process | Where-Object { $_.ProcessName -like "*neurocover*" } | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "==> Removing previous installation (if any)" -ForegroundColor Yellow
try {
    Get-Package -Name "NeuroCover*" -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            Uninstall-Package -Name $_.Name -Force -ErrorAction SilentlyContinue | Out-Null
            Write-Host "  + Removed: $($_.Name)"
        } catch {}
    }
} catch {}
$nsisUninstaller = "$env:LOCALAPPDATA\NeuroCover Focus\uninstall.exe"
if (Test-Path $nsisUninstaller) {
    Start-Process -FilePath $nsisUninstaller -ArgumentList "/S" -Wait -ErrorAction SilentlyContinue
    Write-Host "  + Removed previous NSIS install"
}

$exePath = "$env:TEMP\$EXE_NAME"
Write-Host "==> Downloading $EXE_NAME" -ForegroundColor Yellow
Invoke-WebRequest -Uri "$BASE_URL/$EXE_NAME" -OutFile $exePath -UseBasicParsing
$sizeMB = [math]::Round((Get-Item $exePath).Length / 1MB, 1)
Write-Host "  + Downloaded $sizeMB MB"

Write-Host "==> Verifying integrity" -ForegroundColor Yellow
$actualHash = (Get-FileHash -LiteralPath $exePath -Algorithm SHA256).Hash
if ($actualHash -ne $EXPECTED_SHA256) {
    Write-Host "ERROR: SHA256 mismatch" -ForegroundColor Red
    Write-Host "  Expected: $EXPECTED_SHA256"
    Write-Host "  Actual:   $actualHash"
    Remove-Item $exePath -ErrorAction SilentlyContinue
    return
}
Write-Host "  + SHA256 verified"

Write-Host "==> Installing NeuroCover Focus" -ForegroundColor Yellow
$proc = Start-Process -FilePath $exePath -ArgumentList "/S" -PassThru -Wait
Remove-Item $exePath -ErrorAction SilentlyContinue
if ($proc.ExitCode -ne 0) {
    Write-Host "  ! Installer exited with code $($proc.ExitCode)" -ForegroundColor Red
    return
}
Write-Host "  + Installed" -ForegroundColor Green

Write-Host ""
Write-Host "NeuroCover Focus $VERSION installed successfully." -ForegroundColor Green
Write-Host "Open from Start Menu: NeuroCover Focus" -ForegroundColor Cyan
Write-Host "It will run in your system tray." -ForegroundColor DarkGray
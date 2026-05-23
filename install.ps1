# NeuroCover Focus - Pilot Installer (NSIS, per-user install)
# No admin elevation needed. Bypasses Windows Installer policy restrictions
# (no more error 1625 / Smart App Control rejections).

$ErrorActionPreference = "Stop"
$VERSION = "0.1.2"
$EXE_NAME = "NeuroCover-Focus-0.1.2_x64-setup.exe"
$EXPECTED_SHA256 = "$workDir = "C:\Users\NEUROPAUSE LAB\Desktop\neurocover-releases" $exeHash = Get-Clipboard  # NSIS hash from Block 1 $msiName = "NeuroCover-Focus-0.1.2_x64_en-US.msi" $exeName = "NeuroCover-Focus-0.1.2_x64-setup.exe"  Write-Host "Using NSIS hash: $exeHash" -ForegroundColor Cyan Set-Location $workDir  # --- Write new install.ps1 (NSIS-based) --- $installScript = @' # NeuroCover Focus - Pilot Installer (NSIS, per-user install) # No admin elevation needed. Bypasses Windows Installer policy restrictions # (no more error 1625 / Smart App Control rejections).  $ErrorActionPreference = "Stop" $VERSION = "0.1.2" $EXE_NAME = "NeuroCover-Focus-0.1.2_x64-setup.exe" $EXPECTED_SHA256 = "HASH_PLACEHOLDER" $BASE_URL = "https://github.com/dishantdobariya91-debug/neurocover-releases/releases/download/v0.1.2"  Write-Host "" Write-Host "NeuroCover Focus -- Pilot Installer" -ForegroundColor Cyan Write-Host "Version $VERSION (per-user install)" -ForegroundColor Cyan Write-Host ""  # --- System check --- Write-Host "==> Checking system" -ForegroundColor Yellow Write-Host "  + PowerShell $($PSVersionTable.PSVersion)" Write-Host "  + OS: $((Get-CimInstance Win32_OperatingSystem).Caption)" $arch = if ([Environment]::Is64BitOperatingSystem) { "64-bit" } else { "32-bit" } Write-Host "  + Architecture: $arch" if (-not [Environment]::Is64BitOperatingSystem) {     Write-Host "ERROR: 64-bit Windows required" -ForegroundColor Red     return }  # --- Stop running instance --- Get-Process | Where-Object { $_.ProcessName -like "*neurocover*" } | Stop-Process -Force -ErrorAction SilentlyContinue  # --- Remove any previous installation (MSI from v0.1.0/v0.1.1, or earlier NSIS) --- Write-Host "==> Removing previous installation (if any)" -ForegroundColor Yellow try {     Get-Package -Name "NeuroCover*" -ErrorAction SilentlyContinue | ForEach-Object {         try {             Uninstall-Package -Name $_.Name -Force -ErrorAction SilentlyContinue | Out-Null             Write-Host "  + Removed: $($_.Name)"         } catch {}     } } catch {} $nsisUninstaller = "$env:LOCALAPPDATA\NeuroCover Focus\uninstall.exe" if (Test-Path $nsisUninstaller) {     Start-Process -FilePath $nsisUninstaller -ArgumentList "/S" -Wait -ErrorAction SilentlyContinue     Write-Host "  + Removed previous NSIS install" }  # --- Download --- $exePath = "$env:TEMP\$EXE_NAME" Write-Host "==> Downloading $EXE_NAME" -ForegroundColor Yellow Invoke-WebRequest -Uri "$BASE_URL/$EXE_NAME" -OutFile $exePath -UseBasicParsing $sizeMB = [math]::Round((Get-Item $exePath).Length / 1MB, 1) Write-Host "  + Downloaded $sizeMB MB"  # --- Verify --- Write-Host "==> Verifying integrity" -ForegroundColor Yellow $actualHash = (Get-FileHash -LiteralPath $exePath -Algorithm SHA256).Hash if ($actualHash -ne $EXPECTED_SHA256) {     Write-Host "ERROR: SHA256 mismatch" -ForegroundColor Red     Write-Host "  Expected: $EXPECTED_SHA256"     Write-Host "  Actual:   $actualHash"     Remove-Item $exePath -ErrorAction SilentlyContinue     return } Write-Host "  + SHA256 verified"  # --- Install (silent, no admin needed) --- Write-Host "==> Installing NeuroCover Focus" -ForegroundColor Yellow $proc = Start-Process -FilePath $exePath -ArgumentList "/S" -PassThru -Wait Remove-Item $exePath -ErrorAction SilentlyContinue if ($proc.ExitCode -ne 0) {     Write-Host "  ! Installer exited with code $($proc.ExitCode)" -ForegroundColor Red     return } Write-Host "  + Installed" -ForegroundColor Green  Write-Host "" Write-Host "NeuroCover Focus $VERSION installed successfully." -ForegroundColor Green Write-Host "Open from Start Menu: NeuroCover Focus" -ForegroundColor Cyan Write-Host "It will run in your system tray." -ForegroundColor DarkGray '@  # Substitute the actual hash, write as ASCII (no BOM) $installScript = $installScript.Replace("HASH_PLACEHOLDER", $exeHash) [System.IO.File]::WriteAllText("$workDir\install.ps1", $installScript, [System.Text.Encoding]::ASCII) Write-Host "install.ps1 rewritten for NSIS install (no BOM, NSIS .exe-based)" -ForegroundColor Green  # Verify hash is in file if ((Get-Content "$workDir\install.ps1" -Raw) -match [regex]::Escape($exeHash)) {     Write-Host "Hash present in install.ps1 - OK" -ForegroundColor Green } else {     Write-Host "WARNING: hash substitution didn't take. Open install.ps1 to check." -ForegroundColor Yellow }  # --- Git commit + push --- git add install.ps1 git commit -m "v0.1.2 release - Phase 2A restart memory + NSIS installer + idle decay + coherence tile" git push  # --- Delete old release, create new one with BOTH artifacts --- gh release delete v0.1.1 --yes gh release create v0.1.2 `     "$workDir\$exeName" `     "$workDir\$msiName" `     --title "NeuroCover Focus 0.1.2 - Phase 2A + NSIS Installer" `     --notes @" Phase 2A and pilot-driven fixes.  **Highlights** - Restart Memory Reconstruction: Focus Time and Longest Today now survive app restart - NSIS per-user installer (.exe) - bypasses MSI policy / Smart App Control / error 1625 - Idle exponential decay (canon section 17) - smooth continuity, no 5-min cliff - Workflow Coherence Dashboard tile  **Installation** - Recommended: NSIS .exe - no admin needed, no MSI policy issues - Fallback: MSI - per-machine install, requires admin  NSIS SHA256: $exeHash MSI SHA256:  $msiHash  Unsigned - SmartScreen may warn (More info > Run anyway). "@  Write-Host "" Write-Host "=========================================" -ForegroundColor Green Write-Host "v0.1.2 released" -ForegroundColor Green Write-Host "=========================================" -ForegroundColor Green Write-Host "" Write-Host "Install command (paste into fresh PowerShell):" -ForegroundColor Cyan Write-Host "" Write-Host "iex ((iwr 'https://raw.githubusercontent.com/dishantdobariya91-debug/neurocover-releases/main/install.ps1' -UseBasicParsing).Content.TrimStart([char]0xFEFF))" -ForegroundColor White"
$BASE_URL = "https://github.com/dishantdobariya91-debug/neurocover-releases/releases/download/v0.1.2"

Write-Host ""
Write-Host "NeuroCover Focus -- Pilot Installer" -ForegroundColor Cyan
Write-Host "Version $VERSION (per-user install)" -ForegroundColor Cyan
Write-Host ""

# --- System check ---
Write-Host "==> Checking system" -ForegroundColor Yellow
Write-Host "  + PowerShell $($PSVersionTable.PSVersion)"
Write-Host "  + OS: $((Get-CimInstance Win32_OperatingSystem).Caption)"
$arch = if ([Environment]::Is64BitOperatingSystem) { "64-bit" } else { "32-bit" }
Write-Host "  + Architecture: $arch"
if (-not [Environment]::Is64BitOperatingSystem) {
    Write-Host "ERROR: 64-bit Windows required" -ForegroundColor Red
    return
}

# --- Stop running instance ---
Get-Process | Where-Object { $_.ProcessName -like "*neurocover*" } | Stop-Process -Force -ErrorAction SilentlyContinue

# --- Remove any previous installation (MSI from v0.1.0/v0.1.1, or earlier NSIS) ---
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

# --- Download ---
$exePath = "$env:TEMP\$EXE_NAME"
Write-Host "==> Downloading $EXE_NAME" -ForegroundColor Yellow
Invoke-WebRequest -Uri "$BASE_URL/$EXE_NAME" -OutFile $exePath -UseBasicParsing
$sizeMB = [math]::Round((Get-Item $exePath).Length / 1MB, 1)
Write-Host "  + Downloaded $sizeMB MB"

# --- Verify ---
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

# --- Install (silent, no admin needed) ---
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
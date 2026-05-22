# NeuroCover Focus -- Pilot Installer
# Usage: iex ((iwr 'https://raw.githubusercontent.com/dishantdobariya91-debug/neurocover-releases/main/install.ps1' -UseBasicParsing).Content)

$ErrorActionPreference = "Stop"

$Version       = "0.1.0"
$ProductName   = "NeuroCover Focus"
$RepoOrg       = "dishantdobariya91-debug"
$RepoName      = "neurocover-releases"
$InstallerFile = "NeuroCover-Focus-${Version}_x64_en-US.msi"
$BaseURL       = "https://github.com/$RepoOrg/$RepoName/releases/download/v$Version"
$URL           = "$BaseURL/$InstallerFile"
$ExpectedHash  = "55523B43AA977E1D96EA247013B5B84CBC78E6FADD0DCDAF9DF1B61D623AA289"

function Write-Step($Message) {
    Write-Host ""
    Write-Host "==> " -NoNewline -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor White
}
function Write-OK($Message)   { Write-Host "  + " -NoNewline -ForegroundColor Green; Write-Host $Message -ForegroundColor Gray }
function Write-Fail($Message) { Write-Host "  ! " -NoNewline -ForegroundColor Red;   Write-Host $Message -ForegroundColor Red }

Write-Host ""
Write-Host "$ProductName -- Pilot Installer" -ForegroundColor Magenta
Write-Host "Version $Version" -ForegroundColor DarkGray

Write-Step "Checking system"
if ($PSVersionTable.PSVersion.Major -lt 5) { Write-Fail "PowerShell 5+ required."; return }
Write-OK "PowerShell $($PSVersionTable.PSVersion)"
$os = (Get-CimInstance Win32_OperatingSystem).Caption
if ($os -notmatch "Windows 1[01]") { Write-Fail "Windows 10/11 required."; return }
Write-OK "OS: $os"
if (-not [System.Environment]::Is64BitOperatingSystem) { Write-Fail "64-bit Windows required."; return }
Write-OK "Architecture: 64-bit"

Write-Step "Downloading $InstallerFile"
$TempPath = Join-Path $env:TEMP $InstallerFile
if (Test-Path $TempPath) { Remove-Item $TempPath -Force }
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $URL -OutFile $TempPath -UseBasicParsing
    $ProgressPreference = 'Continue'
} catch {
    Write-Fail "Download failed: $($_.Exception.Message)"
    return
}
$fileSize = (Get-Item $TempPath).Length / 1MB
Write-OK ("Downloaded {0:N1} MB" -f $fileSize)

Write-Step "Verifying integrity"
$actualHash = (Get-FileHash $TempPath -Algorithm SHA256).Hash
if ($actualHash -ne $ExpectedHash) {
    Write-Fail "Hash mismatch."
    Write-Host "  Expected: $ExpectedHash" -ForegroundColor DarkGray
    Write-Host "  Actual:   $actualHash" -ForegroundColor DarkGray
    Remove-Item $TempPath -Force -ErrorAction SilentlyContinue
    return
}
Write-OK "SHA256 verified"

Write-Step "Installing $ProductName (admin elevation required)"
$msiArgs = @("/i", "`"$TempPath`"", "/qb")
try {
    $process = Start-Process "msiexec.exe" -ArgumentList $msiArgs -Wait -PassThru -Verb RunAs
    if ($process.ExitCode -ne 0) { Write-Fail "Installer exited with code $($process.ExitCode)"; return }
} catch {
    Write-Fail "Install failed: $($_.Exception.Message)"
    return
}
Write-OK "Installed"
Remove-Item $TempPath -Force -ErrorAction SilentlyContinue

Write-Step "Launching"
$exePath = "C:\Program Files\NeuroCover Focus\neurocover-focus.exe"
if (Test-Path $exePath) {
    Start-Process $exePath
    Write-OK "Launched"
}

Write-Host ""
Write-Host "Installation complete." -ForegroundColor Green
Write-Host ""

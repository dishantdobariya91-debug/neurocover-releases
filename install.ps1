# NeuroCover Focus — Pilot Installer
# Usage: iex (iwr 'https://raw.githubusercontent.com/dishantdobariya91-debug/neurocover-releases/main/install.ps1').Content

[CmdletBinding()]
param(
    [string]$Version = "0.1.0",
    [switch]$Quiet = $false,
    [switch]$NoLaunch = $false
)

$ErrorActionPreference = "Stop"

$ProductName   = "NeuroCover Focus"
$RepoOrg       = "dishantdobariya91-debug"
$RepoName      = "neurocover-releases"
$InstallerFile = "NeuroCover-Focus-${Version}_x64_en-US.msi"
$BaseURL       = "https://github.com/$RepoOrg/$RepoName/releases/download/v$Version"
$URL           = "$BaseURL/$InstallerFile"

$ExpectedHashes = @{
    "0.1.0" = "55523B43AA977E1D96EA247013B5B84CBC78E6FADD0DCDAF9DF1B61D623AA289"
}

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
Write-Host ""

Write-Step "Checking system"
if ($PSVersionTable.PSVersion.Major -lt 5) { Write-Fail "PowerShell 5+ required."; exit 1 }
Write-OK "PowerShell $($PSVersionTable.PSVersion)"

$os = (Get-CimInstance Win32_OperatingSystem).Caption
if ($os -notmatch "Windows 1[01]") { Write-Fail "Windows 10/11 required."; exit 1 }
Write-OK "OS: $os"

if (-not [System.Environment]::Is64BitOperatingSystem) { Write-Fail "64-bit Windows required."; exit 1 }
Write-OK "Architecture: 64-bit"

if (-not $ExpectedHashes.ContainsKey($Version)) {
    Write-Fail "No SHA256 registered for version $Version."
    exit 1
}
$ExpectedHash = $ExpectedHashes[$Version]
Write-OK "Hash registered for v$Version"

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
    Write-Host "  URL: $URL" -ForegroundColor DarkGray
    exit 1
}
$fileSize = (Get-Item $TempPath).Length / 1MB
Write-OK ("Downloaded {0:N1} MB" -f $fileSize)

Write-Step "Verifying integrity"
$actualHash = (Get-FileHash $TempPath -Algorithm SHA256).Hash
if ($actualHash -ne $ExpectedHash) {
    Write-Fail "Hash mismatch -- file may be corrupted."
    Write-Host "  Expected: $ExpectedHash" -ForegroundColor DarkGray
    Write-Host "  Actual:   $actualHash" -ForegroundColor DarkGray
    Remove-Item $TempPath -Force -ErrorAction SilentlyContinue
    exit 1
}
Write-OK "SHA256 verified"

Write-Step "Installing $ProductName (admin elevation required)"
$msiArgs = @("/i", "`"$TempPath`"")
if ($Quiet) { $msiArgs += "/qn" } else { $msiArgs += "/qb" }

try {
    $process = Start-Process "msiexec.exe" -ArgumentList $msiArgs -Wait -PassThru -Verb RunAs
    if ($process.ExitCode -ne 0) { Write-Fail "Installer exited with code $($process.ExitCode)"; exit $process.ExitCode }
} catch {
    Write-Fail "Install failed: $($_.Exception.Message)"
    exit 1
}
Write-OK "Installed"

Remove-Item $TempPath -Force -ErrorAction SilentlyContinue

if (-not $NoLaunch) {
    Write-Step "Launching"
    $exePath = "C:\Program Files\NeuroCover Focus\neurocover-focus.exe"
    if (Test-Path $exePath) {
        Start-Process $exePath
        Write-OK "Launched"
    }
}

Write-Host ""
Write-Host "Installation complete." -ForegroundColor Green
Write-Host ""

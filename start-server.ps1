param(
  [int]$Port = 8787
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$bundledPython = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"

if (Test-Path $bundledPython) {
  $python = $bundledPython
} else {
  $pythonCommand = Get-Command python -ErrorAction SilentlyContinue
  if ($pythonCommand) {
    $python = $pythonCommand.Source
  } else {
    $pyCommand = Get-Command py -ErrorAction SilentlyContinue
    if ($pyCommand) {
      $python = $pyCommand.Source
    } else {
      throw "Python tidak ditemui. Pasang Python atau jalankan melalui Codex runtime bundled."
    }
  }
}

Write-Host "Lawatan Tapak PWA"
Write-Host "Folder: $projectRoot"
Write-Host "Windows link: http://localhost:$Port"
Write-Host "Telefon WiFi: http://IP-KOMPUTER:$Port"
Write-Host ""
Write-Host "Tekan Ctrl+C untuk hentikan server."

Set-Location $projectRoot
& $python -m http.server $Port --bind 0.0.0.0

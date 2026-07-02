# Bootstrap the native platform folders for cinemory_mobile (Windows / PowerShell).
#
# The repo does not commit android/ or ios/. This regenerates them with
# `flutter create` and injects the photo/media permissions. The founder can run
# and test the ANDROID app on Windows after this; iOS compilation requires macOS
# (see README + docs/STORE_SUBMISSION.md) and happens in cloud CI.
#
#   pwsh tool/bootstrap.ps1
$ErrorActionPreference = "Stop"

$org  = "com.upgradedev"
$name = "cinemory_mobile"

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Error "flutter not found on PATH"; exit 1
}

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("cinemory_boot_" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
  Write-Host "==> generating platform scaffolding (flutter create)"
  flutter create --org $org --project-name $name --platforms=android,ios $tmp | Out-Null

  Write-Host "==> copying android/ and ios/ into the repo"
  if (Test-Path android) { Remove-Item -Recurse -Force android }
  if (Test-Path ios)     { Remove-Item -Recurse -Force ios }
  Copy-Item -Recurse (Join-Path $tmp "android") ./android
  Copy-Item -Recurse (Join-Path $tmp "ios") ./ios

  Write-Host "==> injecting photo/media permissions"
  python tool/apply_platform_overlays.py

  Write-Host "==> flutter pub get"
  flutter pub get

  Write-Host "Done. Run the Android app with: flutter run"
}
finally {
  Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}

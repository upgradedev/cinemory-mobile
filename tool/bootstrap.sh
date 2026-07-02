#!/usr/bin/env bash
# Bootstrap the native platform folders for cinemory_mobile.
#
# The repo intentionally does NOT commit android/ or ios/ (nor the binary
# gradle-wrapper.jar or the Xcode project). Instead we let `flutter create`
# generate them fresh, then inject the photo/media permissions. This keeps the
# committed surface small, avoids binary blobs, and stays reproducible.
#
# Run once after cloning, and any time you change the Flutter SDK:
#   bash tool/bootstrap.sh
set -euo pipefail

ORG="com.upgradedev"
NAME="cinemory_mobile"

command -v flutter >/dev/null 2>&1 || {
  echo "error: flutter not found on PATH" >&2
  exit 1
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "==> generating platform scaffolding (flutter create)"
flutter create --org "$ORG" --project-name "$NAME" \
  --platforms=android,ios "$tmp" >/dev/null

echo "==> copying android/ and ios/ into the repo"
rm -rf android ios
cp -r "$tmp/android" ./android
cp -r "$tmp/ios" ./ios

echo "==> injecting photo/media permissions"
python3 tool/apply_platform_overlays.py

echo "==> flutter pub get"
flutter pub get

echo "Done. You can now: flutter run  (Android on Windows; iOS needs macOS)."

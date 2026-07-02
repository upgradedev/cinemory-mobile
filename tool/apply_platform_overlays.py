#!/usr/bin/env python3
"""Inject Cinemory's photo/media permissions into the flutter-generated
platform manifests.

`flutter create` produces a stock AndroidManifest.xml and ios/Runner/Info.plist
with no photo-library permissions. Rather than commit full hand-written copies
(which drift from the generated package/config), we inject just the permission
lines here. The script is idempotent — safe to run on every CI build and after
any future `flutter create`.

Run from the repo root, AFTER bootstrap has generated android/ and ios/:
    python3 tool/apply_platform_overlays.py
"""
from __future__ import annotations

import sys
from pathlib import Path

ANDROID_MANIFEST = Path("android/app/src/main/AndroidManifest.xml")
IOS_PLIST = Path("ios/Runner/Info.plist")

ANDROID_PERMISSIONS = """
    <!-- Cinemory: on-device photo access via photo_manager (MediaStore). -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
    <uses-permission android:name="android.permission.READ_MEDIA_VISUAL_USER_SELECTED" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.ACCESS_MEDIA_LOCATION" />
    <!-- Cinemory: save the finished reel to the gallery on older Android (gal). -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="29" />
"""

IOS_KEYS = """	<key>NSPhotoLibraryUsageDescription</key>
	<string>Cinemory needs access to your photos so you can pick the moments for your reel. Photos stay on your device unless you choose to share a finished reel.</string>
	<key>NSPhotoLibraryAddUsageDescription</key>
	<string>Cinemory saves your finished reel to your photo library.</string>
"""

ANDROID_MARKER = "READ_MEDIA_IMAGES"
IOS_MARKER = "NSPhotoLibraryUsageDescription"


def patch_android() -> bool:
    if not ANDROID_MANIFEST.exists():
        print(f"skip android: {ANDROID_MANIFEST} not found (run bootstrap first)")
        return False
    text = ANDROID_MANIFEST.read_text(encoding="utf-8")
    if ANDROID_MARKER in text:
        print("android: permissions already present, nothing to do")
        return True
    open_tag_end = text.find(">", text.find("<manifest"))
    if open_tag_end == -1:
        print("android: could not find <manifest> tag", file=sys.stderr)
        return False
    patched = text[: open_tag_end + 1] + "\n" + ANDROID_PERMISSIONS + text[open_tag_end + 1 :]
    ANDROID_MANIFEST.write_text(patched, encoding="utf-8")
    print("android: injected photo/media permissions")
    return True


def patch_ios() -> bool:
    if not IOS_PLIST.exists():
        print(f"skip ios: {IOS_PLIST} not found (run bootstrap first)")
        return False
    text = IOS_PLIST.read_text(encoding="utf-8")
    if IOS_MARKER in text:
        print("ios: permission keys already present, nothing to do")
        return True
    idx = text.rfind("</dict>")
    if idx == -1:
        print("ios: could not find closing </dict>", file=sys.stderr)
        return False
    patched = text[:idx] + IOS_KEYS + text[idx:]
    IOS_PLIST.write_text(patched, encoding="utf-8")
    print("ios: injected NSPhotoLibrary usage descriptions")
    return True


def main() -> int:
    ok_android = patch_android()
    ok_ios = patch_ios()
    # A missing platform folder is not fatal (CI may build one platform only),
    # but a real parse failure is.
    if ok_android is False and ANDROID_MANIFEST.exists():
        return 1
    if ok_ios is False and IOS_PLIST.exists():
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

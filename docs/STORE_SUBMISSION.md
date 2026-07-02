# Store submission — exact steps (and what is blocked on paid accounts)

This is the founder-only path to the App Store and Google Play. None of it can
be completed in CI or by the agent: it requires **paid developer accounts** and
identity verification tied to a person/company.

---

## What is blocked and why

| Blocker | Cost | Why it can't be automated here |
|---|---|---|
| **Apple Developer Program** membership | **$99 / year** | Required to create signing certificates, provisioning profiles, an App ID, and to upload to TestFlight/App Store. Needs Apple ID + legal identity (or D-U-N-S for an org). |
| **iOS code signing** | included above | A distribution certificate + provisioning profile must be generated under the paid account and installed on the macOS build. The CI `build-ios` job builds **unsigned** (`--no-codesign`) — it proves the app *compiles*, not that it can ship. |
| **Google Play Developer** account | **$25 one-time** | Required to create the Play Console app, upload an AAB, and manage release tracks. Needs identity verification. |
| **App Store review / Play review** | free but manual | Human review, days of latency, can request changes. |

The Flutter code, both platform targets, and CI are done. Everything below is
account-gated user action.

---

## A. iOS → App Store

> iOS **compilation requires macOS + Xcode**. The founder develops on Windows,
> so day-to-day iOS builds run in the `build-ios` GitHub Actions job on a
> `macos-latest` runner. Signing + upload still need a Mac (local, a CI runner
> with secrets, or a Mac cloud) under the paid account.

1. **Enrol** in the Apple Developer Program — <https://developer.apple.com/programs/enroll/> ($99/yr).
2. In **App Store Connect** (<https://appstoreconnect.apple.com>) create a new app:
   - Bundle ID: `com.upgradedev.cinemoryMobile` (matches `--org com.upgradedev`
     + project name; confirm in `ios/Runner.xcodeproj` after bootstrap).
   - Name: **Cinemory**. Primary language, category (Photo & Video).
3. **Signing**: in Xcode → Runner target → Signing & Capabilities, select your
   Team; let Xcode manage automatic signing (creates the distribution cert +
   provisioning profile). Add the **Photo Library** usage — already declared via
   `NSPhotoLibraryUsageDescription` / `NSPhotoLibraryAddUsageDescription`.
4. **Privacy nutrition label** (required): declare Photos access. Cinemory reads
   photos **on device**; if you don't upload user photos to a server, declare no
   data collection/tracking accordingly. (Revisit once the photo-upload endpoint
   ships — see repo README "Known gap".)
5. **Build + upload** an archive:
   ```bash
   flutter build ipa --release           # produces build/ios/archive + ipa
   xcrun altool --upload-app -f build/ios/ipa/*.ipa \
        -u <apple-id> -p <app-specific-password>
   # or open build/ios/archive/Runner.xcarchive in Xcode Organizer → Distribute.
   ```
6. In App Store Connect: attach the build to a version, fill screenshots
   (6.7" + 5.5" required), description, keywords, support URL, privacy policy URL.
7. Submit for **review**. Optionally push to **TestFlight** first for beta testers.

## B. Android → Google Play

1. **Register** a Google Play Developer account — <https://play.google.com/console/signup> ($25 one-time).
2. Create an app in the **Play Console**: name **Cinemory**, default language,
   app/game = App, free/paid.
3. **App signing**: opt into **Play App Signing** (Google holds the app signing
   key). Generate an **upload keystore** locally:
   ```bash
   keytool -genkey -v -keystore cinemory-upload.jks -keyalg RSA \
       -keysize 2048 -validity 10000 -alias upload
   ```
   Configure `android/key.properties` + `android/app/build.gradle` signingConfig
   (the keystore is **gitignored** — never commit it).
4. **Build a release App Bundle**:
   ```bash
   flutter build appbundle --release      # build/app/outputs/bundle/release/app-release.aab
   ```
5. In the Play Console: complete the **Data safety** form (declare Photos/Media
   access + `READ_MEDIA_IMAGES`/`READ_MEDIA_VIDEO` usage), content rating
   questionnaire, target audience, privacy policy URL, and store listing
   (screenshots, feature graphic, short/full description).
6. Upload the `.aab` to a track (Internal testing → Closed → Production).
7. Submit for **review** and roll out.

---

## Checklist of user-only prerequisites

- [ ] Apple Developer Program enrolment ($99/yr) + Apple ID.
- [ ] A Mac (or Mac cloud / CI with signing secrets) for the signed archive/upload.
- [ ] iOS distribution certificate + provisioning profile.
- [ ] Google Play Developer account ($25).
- [ ] Android upload keystore (kept out of git).
- [ ] Privacy policy URL (both stores require it for photo access).
- [ ] Screenshots + store copy for both stores.

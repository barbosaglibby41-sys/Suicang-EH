# Building and packaging TaroEH

## Requirements

- macOS with a supported Xcode version
- iOS 17 SDK or newer
- Apple Developer team for device signing
- Optional: XcodeGen to generate a project from `project.yml`

## Generate and build

```bash
xcodegen generate
xcodebuild -project TaroEH.xcodeproj -scheme TaroEH -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath build/TaroEH.xcarchive archive
```

In Xcode, set `Signing & Capabilities` and your own bundle identifier before archiving.

## Export an IPA

Create an export options plist appropriate for your signing method, then:

```bash
xcodebuild -exportArchive \
  -archivePath build/TaroEH.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath build/export
```

The exported IPA is in `build/export/`. Do not commit signing certificates, provisioning profiles, Keychain data, Cookies, or personal export options containing secrets.

## Release checklist

- Test E-Hentai and ExHentai login separately.
- Test thumbnail and page image loading with an authenticated session.
- Test site-isolated reading progress and offline directories.
- Test download pause, resume, retry, deletion, and app restart recovery.
- Verify the embedded tag database and license files are present.
- Attach the IPA only to a private GitHub Release or distribute through your chosen signing service.

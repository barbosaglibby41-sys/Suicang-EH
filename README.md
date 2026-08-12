# TaroEH · 芋头 E 站

A native SwiftUI E-Hentai / ExHentai client for iPhone and iPad.

> 当前为 v1.7 foundation release。源码可以在 macOS + Xcode 上编译；本项目不提供第三方中转服务，不包含预签名 IPA。

## Features

- E-Hentai / ExHentai source model and switching foundation
- Web login and local Cookie import, stored in Keychain
- Structured gallery tags with namespace/key support
- Built-in EhTagTranslation v7 database (43,704 tags)
- Chinese tag search conversion and tag suggestions
- SwiftData gallery records with legacy UserDefaults migration fallback
- Cookie-aware image pipeline with request coalescing and memory cache
- Site-isolated reading progress, URL cache, offline folders and records
- Real front-page and random-discovery foundation
- Online reader, offline reader and resumable download queue foundation
- iPhone/iPad target with system light/dark appearance

## Build locally

Requirements: macOS, Xcode, iOS 17 SDK, and a signing team.

1. Open the repository on a Mac.
2. Generate an Xcode project from `project.yml` with XcodeGen, or add the `TaroEH` folder to a new iOS App target.
3. Set a unique bundle identifier and select your Apple Developer team.
4. Build and run on a device. A free Apple ID can be used for personal testing, subject to Apple's provisioning limits.

This iSH environment cannot run Xcode or produce a signed IPA. See `BUILDING.md` for the release checklist.

## Privacy and network

TaroEH connects directly to the selected site. Cookies are stored locally in Keychain and are not sent to a project server. Follow the target website's rules and applicable law.

## Attribution

- JHenTai architecture ideas: Apache-2.0; see `TaroEH/JHenTai-LICENSE.txt`.
- EhTagTranslation Database: CC BY-NC-SA 3.0 CN; see `TaroEH/EhTagTranslation-LICENSE.md` and `TaroEH/NOTICE`.

## Release

- Current version: `1.7.0`
- Release notes: `RELEASE_NOTES_v1.7.md`
- Changelog: `CHANGELOG.md`

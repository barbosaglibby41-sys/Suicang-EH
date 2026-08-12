# TaroEH v1.7.0

## Release status

Source release and architecture foundation. This release has not yet been built or signed into an IPA; build with Xcode on macOS. An unsigned IPA-shaped artifact may be packaged by CI, but it still must be signed with your own Apple ID before iOS can run it.

## Highlights

- Added E-Hentai / ExHentai site model and switching foundation.
- Added structured gallery tags with namespace and key fields.
- Added SwiftData gallery persistence with legacy UserDefaults fallback/migration.
- Added Cookie-aware image pipeline with request coalescing and memory cache.
- Isolated reading progress, image URL cache, offline folders, and gallery records by site + gid.
- Added Cookie installation for web login, imported cookies, image requests, and downloads.
- Added real front-page and random-discovery request foundation.
- Improved gallery and thumbnail parsing against real E-Hentai-style HTML.
- Retained EhTagTranslation v7 local database, Chinese search conversion, suggestions, update, and restore.

## Validation

- EhPanda parser fixture checked with 100 gallery matches and 100 thumbnail matches.
- Embedded tag database: version 7, 43,704 entries.
- Xcode/iPhone build validation is still required.

## Legal and privacy

TaroEH connects directly to the selected site and does not provide a relay server. Cookies are stored locally in Keychain. Follow the target site's rules and applicable law. See NOTICE and EhTagTranslation-LICENSE.md.

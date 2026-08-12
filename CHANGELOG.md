# Changelog

## 1.7.0 - Foundation

- Dual E-Hentai / ExHentai source model and settings switch.
- Structured `GalleryTag` model.
- SwiftData `GalleryRecord` persistence with legacy migration fallback.
- Cookie-aware `ImagePipeline` replacing the main `AsyncImage` call sites.
- Site-isolated reading progress, image URL cache, and offline storage.
- Dynamic Cookie usage in the downloader.
- Real front-page and random-discovery foundation.
- Improved HTML parsing and thumbnail extraction.
- Retained v1.6 tag translation database and search features.

## 1.6.0 - Tag Translation

- Embedded EhTagTranslation database v7.
- Chinese tag search conversion and tag suggestions.
- Local database update and restore-to-bundled-version actions.

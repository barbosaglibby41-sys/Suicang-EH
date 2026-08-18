# TaroEH Non-sensitive Migration Bundle

This directory is intentionally a **schema and test-fixture home**, not a place for real user exports.

## What may be imported

```json
{
  "id": "unique-export-id",
  "sourceVersion": 1,
  "galleries": [
    {
      "key": "e-hentai:123",
      "title": "Example",
      "pageCount": 20,
      "uploader": "",
      "category": "",
      "thumbnailUrl": "https://...",
      "sourceUrl": "https://...",
      "tagsJson": "[]"
    }
  ],
  "favorites": ["e-hentai:123"],
  "history": ["e-hentai:123"],
  "progress": [
    {
      "key": "e-hentai:123",
      "pageIndex": 4,
      "pageCount": 20,
      "updatedAt": "2026-08-19T00:00:00.000Z"
    }
  ]
}
```

## Never include

- Cookie headers, names, or values
- Keychain exports
- WebView sessions
- passwords, tokens, API keys
- private local file paths

The importer journals `id + SHA-256 checksum`; importing the same completed bundle again is a no-op. The original Swift app data must remain untouched until the user has verified the Flutter import.

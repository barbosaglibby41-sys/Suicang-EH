import Foundation

enum DemoData {
    static let galleries: [Gallery] = [
        Gallery(id: 1, title: "Welcome to TaroEH", uploader: "Local Demo", category: "Demo", thumbnailURL: URL(string: "https://placehold.co/480x680/24222d/b8b5ff?text=TaroEH"), sourceURL: nil, pageCount: 3, tags: [GalleryTag(namespace: "other", key: "local"), GalleryTag(namespace: "other", key: "reader"), GalleryTag(namespace: "other", key: "demo")]),
        Gallery(id: 2, title: "Random Gallery Preview", uploader: "Local Demo", category: "Demo", thumbnailURL: URL(string: "https://placehold.co/480x680/302a3c/f9b8d0?text=Random"), pageCount: 5, tags: ["random", "preview", "collection"].map { GalleryTag(key: $0) }),
        Gallery(id: 3, title: "Offline Library Concept", uploader: "TaroEH", category: "Demo", thumbnailURL: URL(string: "https://placehold.co/480x680/24313f/a8d5e2?text=Library"), pageCount: 12, tags: ["offline", "library", "reading"].map { GalleryTag(key: $0) }),
        Gallery(id: 4, title: "Reader Gesture Preview", uploader: "TaroEH", category: "Demo", thumbnailURL: URL(string: "https://placehold.co/480x680/3a2837/eab4ce?text=Reader"), pageCount: 8, tags: ["gesture", "fullscreen", "preview"].map { GalleryTag(key: $0) })
    ]
    static func pages(for gallery: Gallery) -> [GalleryPage] {
        (1...max(1, gallery.pageCount)).compactMap { n in
            let name = gallery.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "TaroEH"
            guard let url = URL(string: "https://placehold.co/1200x1800/1f1c27/e8e5f0?text=\(name)%0APage+\(n)") else { return nil }
            return GalleryPage(id: n, imageURL: url)
        }
    }
}

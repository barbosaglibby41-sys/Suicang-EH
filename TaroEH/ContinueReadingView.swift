import SwiftUI

struct ContinueReadingCard: View {
    let gallery: Gallery
    @EnvironmentObject private var reading: ReadingStore
    var progress: Double { gallery.pageCount == 0 ? 0 : Double(reading.page(for: gallery) + 1) / Double(gallery.pageCount) }
    var body: some View {
        NavigationLink { gallery.sourceURL == nil ? AnyView(ReaderView(gallery: gallery)) : AnyView(OnlineReaderView(gallery: gallery)) } label: {
            HStack(spacing: 12) { PipelineImage(url: gallery.thumbnailURL, contentMode: .fill).frame(width: 54, height: 72).clipShape(RoundedRectangle(cornerRadius: 8)); VStack(alignment: .leading, spacing: 6) { Text("继续阅读").font(.caption).foregroundStyle(.purple); Text(gallery.title).font(.subheadline.bold()).lineLimit(2); ProgressView(value: progress); Text("第 \(reading.page(for: gallery) + 1) / \(gallery.pageCount) 页").font(.caption).foregroundStyle(.secondary) }; Spacer(); Image(systemName: "chevron.right").foregroundStyle(.secondary) }.padding(12).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
        }.buttonStyle(.plain)
    }
}

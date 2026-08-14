import SwiftUI

struct ContinueReadingCard: View {
    let gallery: Gallery
    @EnvironmentObject private var reading: ReadingStore
    var progressPage: Int { reading.page(for: gallery) }
    var progress: Double { gallery.pageCount == 0 ? 0 : Double(min(progressPage + 1, gallery.pageCount)) / Double(gallery.pageCount) }
    var body: some View {
        NavigationLink { ReaderDestination.view(for: gallery, startIndex: progressPage) } label: {
            HStack(spacing: 12) { PipelineImage(url: gallery.thumbnailURL, contentMode: .fill).frame(width: 54, height: 72).clipShape(RoundedRectangle(cornerRadius: 8)); VStack(alignment: .leading, spacing: 6) { Text("继续阅读").font(.caption).foregroundStyle(.purple); Text(gallery.title).font(.subheadline.bold()).lineLimit(2); ProgressView(value: progress); Text("第 \(min(progressPage + 1, gallery.pageCount)) / \(gallery.pageCount) 页").font(.caption).foregroundStyle(.secondary) }; Spacer(); Image(systemName: "chevron.right").foregroundStyle(.secondary) }.padding(12).background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
        }.buttonStyle(.plain)
    }
}

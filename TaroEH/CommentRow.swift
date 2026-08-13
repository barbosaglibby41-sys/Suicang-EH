import SwiftUI

/// A single gallery comment card: author, relative time, score badge,
/// uploader highlight and (optional) vote breakdown.
struct CommentRow: View {
    let comment: GalleryComment

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(comment.author).font(.subheadline.bold()).lineLimit(1)
                if comment.isUploader {
                    Text("上传者").font(.system(size: 9, weight: .bold)).padding(.horizontal, 6).padding(.vertical, 2).background(Color.purple.opacity(0.15), in: Capsule()).foregroundStyle(.purple)
                }
                Spacer()
                if let score = comment.score {
                    Text(score > 0 ? "+\(score)" : "\(score)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(score > 0 ? .green : score < 0 ? .red : .secondary)
                }
            }
            Text(comment.content).font(.subheadline).textSelection(.enabled)
            HStack(spacing: 6) {
                Image(systemName: "clock").font(.system(size: 10))
                Text(Self.relativeTime(comment.postedAt)).font(.caption2).foregroundStyle(.secondary)
                if let votes = comment.votes, !votes.isEmpty {
                    Text("·").foregroundStyle(.secondary)
                    Image(systemName: "hand.thumbsup").font(.system(size: 10)).foregroundStyle(.secondary)
                    Text(votes).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(comment.isUploader ? Color.purple.opacity(0.07) : Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(comment.isUploader ? RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Color.purple.opacity(0.25), lineWidth: 1) : nil)
    }

    /// "13 August 2026, 13:52" → "3 天前" style relative string.
    private static func relativeTime(_ raw: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMMM yyyy, HH:mm"
        guard let date = formatter.date(from: raw) else { return raw }
        let relative = RelativeDateTimeFormatter()
        relative.locale = Locale(identifier: "zh_CN")
        relative.unitsStyle = .short
        return relative.localizedString(for: date, relativeTo: .now)
    }
}

import Foundation

/// A requestable image and the page that authorized it. Some gallery image
/// hosts reject direct requests without the originating page as Referer.
struct ReaderImageRequest: Hashable {
    let imageURL: URL
    let referer: URL?
}

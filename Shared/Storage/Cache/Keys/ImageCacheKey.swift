import Foundation

struct ImageCacheKey {
    let url: String
    let size: CGSize
}
extension ImageCacheKey: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}

extension ImageCacheKey: CacheKeyProtocol {
    var key: String {
        let safeID = url
            .replacingOccurrences(of: "[^A-Za-z0-9._-]", with: "_", options: .regularExpression)
        return "\(safeID)#\(size)"
    }
}

import UIKit

final class CachedImage {
    let image: UIImage
    let cost: Int
    
    init(_ image: UIImage) {
        self.image = image
        self.cost = Self.calculateCost(for: image)
    }
    
    private static func calculateCost(for image: UIImage) -> Int {
        guard let cgImage = image.cgImage else { return 1 }
        return cgImage.bytesPerRow * cgImage.height
    }
}

extension CachedImage: CostableProtocol {
    var cacheCost: Int { cost }
}

final class CachedData {
    let data: Data
    
    init(_ data: Data) {
        self.data = data
    }
}

extension CachedData: CostableProtocol {
    var cacheCost: Int { data.count }
}

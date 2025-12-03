import UIKit
protocol ImageDownsamplerProtocol: AnyObject {
    func downsample(_ data: Data, to size: CGSize) async -> UIImage?
}

actor ImageDownsampler: ImageDownsamplerProtocol {
    
    private let scale: CGFloat
    
    init(scale: CGFloat = UIScreen.main.scale) {
        self.scale = scale
    }
    
    func downsample(_ data: Data, to size: CGSize) async -> UIImage? {
        let scale = self.scale
        
        return await Task.detached(priority: .userInitiated) {
            let maxSide = max(size.width, size.height)
            let maxDimensionPx = max(Int(maxSide * scale), 1)
            
            let opts: [CFString: Any] = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maxDimensionPx
            ]
            
            guard
                let src = CGImageSourceCreateWithData(data as CFData, nil),
                let cgImage = CGImageSourceCreateThumbnailAtIndex(src, 0, opts as CFDictionary)
            else {
                return nil
            }
            
            let size = CGSize(
                width: cgImage.width,
                height: cgImage.height
            )
            
            let renderer = UIGraphicsImageRenderer(size: size)
            let decodedImage = renderer.image { context in
                UIImage(cgImage: cgImage, scale: scale, orientation: .up)
                    .draw(in: CGRect(origin: .zero, size: size))
            }
            
            return decodedImage
            
        }.value
    }
}

import UIKit

struct ImageViewConfig {
    var contentMode: UIView.ContentMode
    var clipsToBounds: Bool
    var cornerRadius: CGFloat?
    var tintColor: UIColor?

    init(contentMode: UIView.ContentMode = .scaleAspectFill,
         clipsToBounds: Bool = true,
         cornerRadius: CGFloat? = nil,
         tintColor: UIColor? = nil) {
        self.contentMode = contentMode
        self.clipsToBounds = clipsToBounds
        self.cornerRadius = cornerRadius
        self.tintColor = tintColor
    }
}

final class ImageViewFactory {
    @discardableResult
    func make(_ config: ImageViewConfig = .init()) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = config.contentMode
        imageView.clipsToBounds = config.clipsToBounds
        if let radius = config.cornerRadius {
            imageView.layer.cornerRadius = radius
        }
        if let tint = config.tintColor {
            imageView.tintColor = tint
        }
        return imageView
    }
}

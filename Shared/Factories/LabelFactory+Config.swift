import UIKit

struct LabelConfig {
    var font: UIFont
    var textColor: UIColor
    var textAlignment: NSTextAlignment
    var numberOfLines: Int
    var adjustsFontForContentSizeCategory: Bool
    var lineBreakMode: NSLineBreakMode
    var isUserInteractionEnabled: Bool
    var cornerRadius: CGFloat
    var masksToBounds: Bool
    var textInsets: UIEdgeInsets
    var backgroundColor: UIColor
    var isOpaque: Bool = true
    
    init(font: UIFont = .preferredFont(forTextStyle: .body),
         textColor: UIColor = .label,
         textAlignment: NSTextAlignment = .natural,
         numberOfLines: Int = 0,
         adjustsFontForContentSizeCategory: Bool = true,
         lineBreakMode: NSLineBreakMode = .byWordWrapping,
         isUserInteractionEnabled: Bool = true,
         cornerRadius: CGFloat = 0,
         masksToBounds: Bool = false,
         textInsets: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0),
         backgroundColor: UIColor = .secondarySystemBackground,
         isOpaque: Bool = true) {
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.numberOfLines = numberOfLines
        self.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
        self.lineBreakMode = lineBreakMode
        self.isUserInteractionEnabled = isUserInteractionEnabled
        self.cornerRadius = cornerRadius
        self.masksToBounds = masksToBounds
        self.textInsets = textInsets
        self.backgroundColor = backgroundColor
        self.isOpaque = isOpaque
    }
}

final class LabelFactory {
    @discardableResult
    func make(_ config: LabelConfig) -> UILabel {
        let label = PaddedLabel()
        label.font = config.font
        label.textColor = config.textColor
        label.textAlignment = config.textAlignment
        label.numberOfLines = config.numberOfLines
        label.adjustsFontForContentSizeCategory = config.adjustsFontForContentSizeCategory
        label.lineBreakMode = config.lineBreakMode
        label.isUserInteractionEnabled = config.isUserInteractionEnabled
        label.layer.cornerRadius = config.cornerRadius
        label.layer.masksToBounds = config.masksToBounds
        label.textInsets = config.textInsets
        return label
    }
}
